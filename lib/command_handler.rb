
class CommandHandler

  def initialize
  end

  def push_cmd_scope( mob )
    mob.cmd_handlers.push []
  end

  def pop_cmd_scope( mob )
    mob.cmd_handlers.pop
  end

  def scope_size( mob )
    mob.cmd_handlers.size
  end
end
