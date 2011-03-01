require Util.here "authentication.rb"

class AccountSystem
  SPLASH = <<eos
{@{!{FG     ________             ________ \r\n{FG    / ____  /\\           /\\  ____ \\ \r\n{FG   / /\\__/ / _\\_________/_ \\ \\__/\\ \\ \r\n{FG  / /_/_/ / /             \\ \\ \\_\\_\\ \\ \r\n{FG /_______/ /_______________\\ \\_______\\ \r\n{FG \\  ____ \\ \\               / / ____  / \r\n{FG  \\ \\ \\_\\ \\ \\_____________/ / /_/ / / \r\n{FG   \\ \\/__\\ \\  /{FR N O T A{FG \\  / /__\\/ / \r\n{FG    \\_______\\/{FY M   U   D{FG \\/_______/ \r\n{FG  \r\n       {FW+ {FRC a t a l y s t i c a {FW+{@ \r\n \r\n
eos
  
  def initialize( network, authentication )
    raise "network not an instance of Network" unless network.kind_of? Network
    raise "authentication not an instance of Authentication" unless authentication.kind_of? Authentication
    @network = network
    @authentication = authentication
    @accounts_online = {}
    @new_account_connections = []
    @new_account_disconnections = []
  end

  def size
    @accounts_online.size
  end

  def connection( account )
    @accounts_online[account]
  end
  
  def tick
    process_new_network_disconnections
    process_new_network_connections
    process_authentications
  end

  def next_account_connection
    # AccountSystem gurantees that newly connected accounts are not currently connected, although they may be previously disconnected in the same tick, i.e. disconnections must be processed before connections
    @new_account_connections.shift
  end

  def next_account_disconnection
    @new_account_disconnections.shift
  end

  def next_command( account )
    verify_online account
    @network.next_command @accounts_online[account]
  end

  def disconnect( account )
    @network.disconnect @accounts_online[account]
    set_offline account
  end

  def send_msg( account, msg )
    verify_online account
    @network.send @accounts_online[account], msg
  end

  private
  def process_authentications
    @authentication.tick
    while connection = @authentication.next_auth_fail do
      raise "connection should not be nil" unless connection
      @network.disconnect connection
    end
    while success = @authentication.next_auth_success do
      raise "success should not be nil" unless success
      set_online success[:account], success[:connection]
    end
  end
  
  def process_new_network_connections
    while connection = @network.next_connection do
      raise "connection should not be nil" unless connection
      Log::info "connection #{connection} began authenticating", "accounts"
      @authentication.authenticate connection
    end
  end

  def process_new_network_disconnections
    while connection = @network.next_disconnection do
      raise "connection should not be nil" unless connection
      @authentication.disconnect connection
      if @accounts_online.value? connection
        account = @accounts_online.key(connection)
        @new_account_disconnections << account
        Log::info "socket #{connection} disconnected, account #{account.name}", "accounts"
        set_offline account
      end
    end
  end

  def verify_online( account )
    raise "expected #{account.name} to be online" unless @accounts_online.key? account
  end

  def set_online( account, connection )
    Log::info "trying to set account #{account.name} online, socket #{connection}", "accounts"
    disconnect_if_already_online account
    @accounts_online[account] = connection
    @new_account_connections << account
    Log::info "account #{account.name}, socket #{@accounts_online[account]} set online", "accounts"
  end

  def disconnect_if_already_online( account )
    if @accounts_online.key? account
      old_connection = @accounts_online[account]
      Log::info "account #{account.name} already online, socket #{old_connection}, disconnecting", "accounts"
      @network.send old_connection, "Your account has been logged into from somewhere else.\n"
      @network.disconnect old_connection
      @new_account_disconnections << account
      set_offline account
      Log::info "account #{account.name} ready to go online with new socket", "accounts"
    end
  end

  def set_offline( account )
    verify_online account
    Log::info "account #{account.name}, socket #{@accounts_online[account]} set offline", "accounts"
    @accounts_online.delete account
  end
end
