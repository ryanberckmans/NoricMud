
require 'socket'

SERVER = "localhost"
PORT = 4000

def login_char( account, char )
  s = TCPSocket.new SERVER, PORT
  s.send account + "\n", 0
  s.send "pw\n", 0
  s.send "1\n", 0
  s.send char + "\n", 0
  sleep 3
  s
end

$cmds = []
$cmds << "west"
$cmds << "north"
$cmds << "east"
$cmds << "south"
$cmds << "up"
$cmds << "down"
$cmds << "say for the overmind"
$cmds << "shout live for the swarm"
$cmds << "look"
$cmds << "rage"
$cmds << "heal"
$cmds << "hp"
$cmds << "energy"
def random_command
  return "quit" if Random.new.rand(1..100) > 99
  $cmds.sample
end

def async_char
  thread = Thread.new do
    random_char = ""
    10.times { random_char += (Random.new.rand(1..26) + 96).chr }
    random_account = Random.new.rand(10000..40000).to_s
    s = login_char random_account, random_char
    i = 0
    $bots += 1
    while true
      data = s.recv_nonblock(1024) rescue nil
      #puts data if data
      sleep 0.25
      if i > 2
        cmd = random_command
        #puts cmd
        s.send cmd + "\n", 0
        if cmd == "quit"
          $bots -= 1
          Thread.exit
        end
        i = 0
      end
      i += 1
    end
  end
  thread
end
threads = []
$bots = 0
ARGV[0].to_i.times { threads << async_char }
old_bots = nil
while true
  puts "#{$bots} connected" if $bots != old_bots
  old_bots = $bots
  sleep 5
  break if $bots < 1
end
threads.each do |t| t.join end
puts "done"

