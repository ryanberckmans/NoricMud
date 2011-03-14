
module CoreCommands
  def self.help( game, mob )
    help = "HELP COMMANDS ?\n\n"
    help += "Current commands:\n"

    commands = []
    commands << "north"
    commands << "south"
    commands << "up"
    commands << "down"
    commands << "west"
    commands << "east"
    commands << "say"
    commands << "quit"
    commands << "shout"
    commands << "look"
    commands << "exits"
    commands << "hp"
    commands << "energy"
    commands << "flee"
    commands << "glance"
    commands << "kill"
    commands << "slay random"
    commands << "kill random"
    commands << "who"
    commands << "help"
    commands << "?"
    commands << "commands"
    commands << "goto"
    commands << "room create"
    commands << "room default name"

    commands.sort.each do |cmd| help += "#{cmd}\n" end
    game.send_msg mob, help
  end
end
