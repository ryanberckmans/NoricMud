
module CoreCommands
  @commands = AbbrevMap.new
  CORE_COMMANDS_HANDLER_PRIORITY = 2
  
  def self.new( game )
    Public.new game
  end

  def self.add_cmd( cmd, callback )
    @commands.add cmd, callback
  end

  def self.commands
    @commands
  end

  class Public
    def initialize( game )
      @game = game
      @game.mob_commands.add_default_cmd_handler CoreCommands::commands, CORE_COMMANDS_HANDLER_PRIORITY
    end
  end
end

files = Dir.glob Util.here "*.rb"
files.each do |f| require f end
