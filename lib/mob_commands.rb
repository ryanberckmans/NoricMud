require 'depq'

class AbandonCallback < Exception
end

class MobCommands
  def initialize( game )
    raise "expected a Game" unless game.kind_of? Game
    @game = game
    @default_handlers = []
    @mob_handlers = {}
  end

  def add(mob)
    raise "mob already exists" if @mob_handlers[mob]
    @mob_handlers[mob] = Depq.new
    add_default_cmd_handlers mob
    Log::info "added #{mob.short_name}", "mobcommands"
  end

  def remove(mob)
    verify_exists mob
    @mob_handlers.delete mob
    Log::info "removed #{mob.short_name}", "mobcommands"
  end

  def add_default_cmd_handler( handler, priority )
    raise "expected handler to be Proc or AbbrevMap" unless handler.kind_of? AbbrevMap or handler.kind_of? Proc
    raise "expected priority to be Integer" unless priority.kind_of? Fixnum
    @default_handlers << [handler, priority]
  end

  def add_cmd_handler(mob, handler, priority)
    raise "expected handler to be Proc or AbbrevMap" unless handler.kind_of? AbbrevMap or handler.kind_of? Proc
    raise "expected priority to be Integer" unless priority.kind_of? Fixnum
    verify_exists mob
    @mob_handlers[mob].insert handler, priority
  end

  def remove_cmd_handler( mob, handler )
    verify_exists mob
    removed = false
    @mob_handlers[mob].each_locator do |loc|
      next unless loc # hack, sometimes locators are nil
      if loc.value == handler
        @mob_handlers[mob].delete_locator loc
        removed = true
      end
    end
    raise "no handler was matched for removal" unless removed
  end

  def handle_cmd( mob, cmd )
    verify_exists mob
    raise "expected cmd to be a String" unless cmd.kind_of? String
    Log::debug "handling cmd #{cmd} for #{mob.short_name}", "mobcommands"
    cmd_handled = false
    original_size = @mob_handlers[mob].size
    dequeued = []
    begin
      while true
        loc = @mob_handlers[mob].delete_max_locator
        break unless loc
        dequeued << loc

        cmd_handler = loc.value
        cmd_handler = cmd_handler[mob] if cmd_handler.kind_of? Proc
        next unless cmd_handler
        raise "expected cmd_handler to be AbbrevMap" unless cmd_handler.kind_of? AbbrevMap
        
        cmd_func = cmd_handler.find cmd
        next unless cmd_func
        raise "expected cmd_func[:value] to be a Proc" unless cmd_func[:value].kind_of? Proc
        raise "expected cmd_func[:match] to be a String" unless cmd_func[:match].kind_of? String
        raise "expected cmd_func[:rest] to be a String" unless cmd_func[:rest].kind_of? String
        begin
          cmd_func[:value].call( @game, mob, cmd_func[:rest], cmd_func[:match] )
          cmd_handled = true
          break
        rescue AbandonCallback
        end
      end
    ensure
      dequeued.each do |loc|
        raise "expected locator to be a Depq::Locator" unless loc.kind_of? Depq::Locator
        @mob_handlers[mob].insert_locator loc
      end
    end
    raise "expected mob to have same number of handlers after handle_cmd" unless @mob_handlers[mob].size == original_size
    cmd_handled
  end

  private
  def verify_exists( mob )
    raise "expected mob to be present in commandhandler list" unless @mob_handlers[mob]
  end

  def add_default_cmd_handlers( mob )
    @default_handlers.each do |arr|
      handler = arr[0]
      priority = arr[1]
      add_cmd_handler mob, handler, priority
    end
  end
end
