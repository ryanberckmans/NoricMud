require 'depq'

class CommandHandler
  def initialize
    @mob_handlers = {}
  end

  def add(mob)
    raise "mob already exists" if @mob_handlers[mob]
    @mob_handlers[mob] = []
  end

  def remove(mob)
    verify_exists mob
    @mob_handlers.delete mob
  end

  def push_cmd_scope( mob )
    verify_exists mob
    @mob_handlers[mob].push Depq.new
  end

  def pop_cmd_scope( mob )
    verify_exists mob
    verify_has_scope mob
    @mob_handlers[mob].pop
  end

  def add_handler(mob, handler, priority)
    verify_exists mob
    verify_has_scope mob
    @mob_handlers[mob].last.insert handler, priority
  end

  def remove_handler( mob, handler )
    verify_exists mob
    verify_has_scope mob
    removed = false
    @mob_handlers[mob].last.each_locator do |loc|
      if loc.value == handler
        @mob_handlers[mob].last.delete_locator loc
        removed = true
      end
    end
    raise "no handler was matched for removal" unless removed
  end

  private
  def verify_exists( mob )
    raise "expected mob to be present in commandhandler list" unless @mob_handlers[mob]
  end
  
  def verify_has_scope( mob )
    raise "expected mob to have a cmd_scope" if @mob_handlers[mob].empty?
  end
end
