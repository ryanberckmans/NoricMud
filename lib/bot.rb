
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
$cmds << "nosuchcommand"
$cmds << "nosuchcommand"
$cmds << "nosuchcommand"
$cmds << "nosuchcommand"
$cmds << "nosuchcommand"
$cmds << "nosuchcommand"
$cmds << "west"
$cmds << "north"
$cmds << "east"
$cmds << "south"
$cmds << "up"
$cmds << "down"
# $cmds << "say for the overmind"
# $cmds << "shout live for the swarm"
$cmds << "look"
# $cmds << "rage"
# $cmds << "heal"
$cmds << "kill random"
# $cmds << "fight random"
$cmds << "flee"
$cmds << "help"
$cmds << "glance A"
$cmds << "where"
$cmds << "who"
$cmds << "weapon"
$cmds << "cast nuke"
$cmds << "cast stun"
$cmds << "cast heal me"
$cmds << "cast pitter"
$cmds << "cast burst"
$cmds << "cast poison"
$cmds << "cast heal dot me"
$cmds << "cast shield me"
$cmds << "rest"
$cmds << "stand"
$cmds << "meditate"
$cmds << "cooldowns"
def random_command
  return "quit" if Random.new.rand(1..10000) > 9999
  $cmds.sample
end

def async_char( bot_num )
  thread = Thread.new do
    sleep bot_num * 1.0 / 4
    random_char = ""
    10.times { random_char += (Random.new.rand(1..26) + 96).chr }
    random_account = Random.new.rand(10000..40000).to_s
    s = login_char random_account, random_char
    i = 0
    $bots += 1
    puts "bot #{bot_num} connected"
    begin
      while true
        data = s.recv_nonblock(1024) rescue nil
        #puts data if data
        sleep 0.25
        if i > 2
          cmd = random_command
          #puts cmd
          s.send cmd + "\n", 0
          if cmd == "quit"
            Thread.exit
          end
          i = 0
        end
        i += 1
      end
    ensure
      puts "bot #{bot_num} disconnected"
      $bots -= 1
    end
  end
  thread
end

threads = []
$bots = 0
ARGV[0].to_i.times { |i| threads << async_char(i) }
old_bots = nil
while true
  puts "#{$bots} total connected" if $bots != old_bots
  old_bots = $bots
  sleep 5
  break if $bots < 1
end
threads.each do |t| t.join end
puts "done"
