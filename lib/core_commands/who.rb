
module CoreCommands
  def self.who( game, mob )
    who = "{!"
    who += "{FWName\n"
    who += "--------------------------------------\n"
    all_chars = game.all_characters
    all_chars.each do |char|
      who += "{FC#{char.name}\n"
    end
    who += "\n{FW[#{all_chars.size}] Total players visible to you\n"
    game.send_msg mob, who
  end
end
