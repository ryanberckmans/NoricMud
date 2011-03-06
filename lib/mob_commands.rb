require 'depq'

class MobCommands
  def initialize
    @mob_handlers = {}
  end

  def add(mob)
    raise "mob already exists" if @mob_handlers[mob]
    @mob_handlers[mob] = Depq.new
  end

  def remove(mob)
    verify_exists mob
    @mob_handlers.delete mob
  end

  def add_cmd_handler(mob, handler, priority)
    verify_exists mob
    @mob_handlers[mob].insert handler, priority
  end

  def remove_cmd_handler( mob, handler )
    verify_exists mob
    removed = false
    @mob_handlers[mob].each_locator do |loc|
      if loc.value == handler
        @mob_handlers[mob].delete_locator loc
        removed = true
      end
    end
    raise "no handler was matched for removal" unless removed
  end

  def handle_cmd( mob, cmd )
    verify_exists mob
  end

  private
  def verify_exists( mob )
    raise "expected mob to be present in commandhandler list" unless @mob_handlers[mob]
  end
end
