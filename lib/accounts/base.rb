
module Accounts
  @connections = {}

  SPLASH = <<eos
{@{!{FG     ________             ________ \r\n{FG    / ____  /\\           /\\  ____ \\ \r\n{FG   / /\\__/ / _\\_________/_ \\ \\__/\\ \\ \r\n{FG  / /_/_/ / /             \\ \\ \\_\\_\\ \\ \r\n{FG /_______/ /_______________\\ \\_______\\ \r\n{FG \\  ____ \\ \\               / / ____  / \r\n{FG  \\ \\ \\_\\ \\ \\_____________/ / /_/ / / \r\n{FG   \\ \\/__\\ \\  /{FR N O T A{FG \\  / /__\\/ / \r\n{FG    \\_______\\/{FY M   U   D{FG \\/_______/ \r\n{FG  \r\n       {FW+ {FRC a t a l y s t i c a {FW+{@ \r\n \r\n
eos
  def self.tick
    Connections::new_connections.each do |conn_id|
      @connections[ conn_id ] = account_flow conn_id
    end

    Connections::new_disconnections.each do |conn_id|
      @connections.delete conn_id
    end

    @connections.each_value do |flow|
      flow.resume
    end
  end

  private
  def self.wait_for_next_command( conn_id )
    cmd = nil
    while not cmd
      Fiber.yield
      cmd = Connections::next_command conn_id
    end
    cmd
  end

  def self.account_flow( id )
    Fiber.new do
      conn_id = id
      Connections::send conn_id, SPLASH
      account = nil
      while true
        Connections::send conn_id, "{!{FYaccount name{FB> "
        account = Account.new({:name => wait_for_next_command( conn_id)})
        break if account.save
        account.errors.each_value do |err| err.each do |msg| Connections::send conn_id, "{!{FC#{msg}\n" end end
      end
      Connections::send conn_id, "successfully created account #{account.name}"
      Connections::disconnect conn_id
    end
  end
  
  def self.chat_flow( id )
    Fiber.new do
      conn_id = id
      Connections::send conn_id, SPLASH
      Connections::send conn_id, "{!{FB<enter your chat {FGname{FB>{@ "
      name = nil
      while not name or name.length < 1
        Fiber.yield
        name = Connections::next_command conn_id
      end
      Connections::send conn_id, "{!{FYnow chatting as {FC#{name}{FY!{@\r\n"
      while true
        Fiber.yield
        msg = Connections::next_command conn_id
        next unless msg and msg.length > 0
        if msg =~ /^quit$/
          Connections::disconnect conn_id
          break
        end
        @connections.each_key do |other_conn_id|
          Connections::send other_conn_id, "{!{FC#{name}: #{msg}{@\r\n"
        end
      end
    end
  end
end
