require 'noric_mud/mob'

module NoricMud
  module Player
    class Sessions
      def initialize server
        @server = server
        @mob_msgs = {}
        @connections_for_mob = {} # list of connections receiving mob's output
        @mob_for_connection = {} # single mob receiving a connection's cmds
        @new_logins = []
        @new_disconnections = []
      end

      def flush_msgs
        @mob_msgs.each_pair do |mob,msg|
          @connections_for_mob[mob].each do |connection|
            prompt = "\n{!{FUprompt> {@"
            @server.send connection, msg + prompt
          end
        end
        @mob_msgs.clear
        nil
      end

      def next_login
        @new_logins.shift
      end

      def next_disconnection
        raise "disconnect handled internally"
      end

      def next_reconnection
        raise "no support to reconnect"
      end

      def process_commands
        @mob_for_connection.each_pair do |connection,mob|
          cmd = @server.next_command connection
          mob.run_cmd cmd if cmd
        end
      end

      def process_connections
        while connection = @server.next_connection do
          mob = Mob.new
          mob.gender = :male
          mob.short_name = "EveryoneIsNamedBob"
          mob.long_name = "{FY#{mob.short_name}{FG the Assassin Hero"
          mob.description = "Lookin good."
          create_session mob, connection
          @new_logins << mob
        end
      end

      def process_disconnections
        while connection = @server.next_disconnection do
          delete_session connection
        end
      end

      private
      def delete_session connection
        raise "expected connection to have a session" unless @mob_for_connection.key? connection
        @mob_for_connection.delete connection
        raise "expected mob to output to connection" unless @connections_for_mob[mob].include? connection
        @connections_for_mob[mob].delete connection
        mob.has_session = false if @connections_for_mob[mob].empty?
        raise "expected not mob.has_session since we don't support mindlinking yet" if mob.has_session
        mob.lost_link = true
      end
      
      def create_session mob, connection
        raise "expected connection to have no session" if @mob_for_connection.key? connection
        @mob_for_connection[connection] = mob
        @connections_for_mob[mob] ||= []
        raise "expected mob not to output to connection yet" if @connections_for_mob[mob].include? connection
        @connections_for_mob[mob] << connection
        mob.msg_mailbox ||= ->msg{ @mob_msgs[mob] ||= "\n"; @mob_msgs[mob] += msg + "{@" }
        mob.has_session = true
        nil
      end
    end
  end
end
