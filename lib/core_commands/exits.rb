
module CoreCommands
  def self.exits( game, mob )
    return unless mob.room
    room = mob.room
    exits = "{!{FUObvious exits:\n"
    exits += "North  - " + room.north.destination.name + "\n" if room.north
    exits += "East   - " + room.east.destination.name + "\n"  if room.east
    exits += "South  - " + room.south.destination.name + "\n"  if room.south
    exits += "West   - " + room.west.destination.name + "\n"  if room.west
    exits += "Up     - " + room.up.destination.name + "\n"  if room.up
    exits += "Down   - " + room.down.destination.name + "\n"  if room.down
    game.send_msg mob, exits
  end
end
