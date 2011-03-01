require Util.here "authentication.rb"

module AccountSystem
  @connections_authenticating = {}
  @accounts_online = {}
  @new_connections = []
  @new_disconnections = []

  SPLASH = <<eos
{@{!{FG     ________             ________ \r\n{FG    / ____  /\\           /\\  ____ \\ \r\n{FG   / /\\__/ / _\\_________/_ \\ \\__/\\ \\ \r\n{FG  / /_/_/ / /             \\ \\ \\_\\_\\ \\ \r\n{FG /_______/ /_______________\\ \\_______\\ \r\n{FG \\  ____ \\ \\               / / ____  / \r\n{FG  \\ \\ \\_\\ \\ \\_____________/ / /_/ / / \r\n{FG   \\ \\/__\\ \\  /{FR N O T A{FG \\  / /__\\/ / \r\n{FG    \\_______\\/{FY M   U   D{FG \\/_______/ \r\n{FG  \r\n       {FW+ {FRC a t a l y s t i c a {FW+{@ \r\n \r\n
eos

  def self.tick
    @new_connections.clear
    @new_disconnections.clear
    process_new_network_disconnections
    process_new_network_connections
    process_connections_authenticating
  end

  def self.new_connections
    # AccountSystem gurantees that newly connected accounts are not currently connected, although they may be previously disconnected in the same tick, i.e. disconnections must be processed before connections
    @new_connections
  end

  def self.new_disconnections
    @new_disconnections
  end

  def self.next_command( account )
    verify_online account
    Network::next_command @accounts_online[account]
  end

  def self.disconnect( account )
    Network::disconnect @accounts_online[account]
    set_offline account
  end

  def self.send( account, msg )
    verify_online account
    Network::send @accounts_online[account], msg
  end

  private
  def self.process_new_network_connections
    Network::new_connections.each do |connection|
      Log::info "socket #{connection} began authenticating", "accounts"
      @connections_authenticating[ connection ] = account_flow connection
    end
  end

  def self.process_new_network_disconnections
    Network::new_disconnections.each do |connection|
      if @connections_authenticating.key? connection
        @connections_authenticating.delete connection
        Log::info "socket #{connection} disconnected, was currently authenticating", "accounts"
      elsif @accounts_online.value? connection
        account = @accounts_online.key(connection)
        @new_disconnections << account
        Log::info "socket #{connection} disconnected, account #{account.name}", "accounts"
        set_offline account
      else
        raise "disconnected socket #{connection} not found in system", "accounts"
      end
    end
  end

  def self.process_connections_authenticating
    @connections_authenticating.each_value do |account_flow|
      account_flow.resume
    end

    @connections_authenticating.delete_if do |connection,account_flow|
      Log::info "socket #{connection} completed account flow", "accounts" if not account_flow.alive?
      not account_flow.alive?
    end
  end

  def self.verify_online( account )
    raise "expected #{account.name} to be online" unless @accounts_online.key? account
  end

  def self.account_flow( connection )
    Fiber.new do
      Network::send connection, SPLASH
      account = get_account connection
      set_online account, connection
    end
  end

  def self.set_online( account, connection )
    Log::info "trying to set account #{account.name} online, socket #{connection}", "accounts"
    disconnect_if_already_online account
    @accounts_online[account] = connection
    @new_connections << account
    Log::info "account #{account.name}, socket #{@accounts_online[account]} set online", "accounts"
  end

  def self.disconnect_if_already_online( account )
    if @accounts_online.key? account
      old_connection = @accounts_online[account]
      Log::info "account #{account.name} already online, socket #{old_connection}, disconnecting", "accounts"
      Network::send old_connection, "Your account has been logged into from somewhere else.\n"
      Network::disconnect old_connection
      @new_disconnections << account
      set_offline account
      Log::info "account #{account.name} ready to go online with new socket", "accounts"
    end
  end

  def self.set_offline( account )
    verify_online account
    Log::info "account #{account.name}, socket #{@accounts_online[account]} set offline", "accounts"
    @accounts_online.delete account
  end

  def self.get_account( connection )
    account = nil
    while true
      Network::send connection, "{!{FYaccount name{FB> "
      account = Account.find_or_initialize_by_name(Util::InFiber::wait_for_next_command(->{Network::next_command connection}))
      break unless account.new_record?
      break if account.save
      account.errors.each_value do |err| err.each do |msg| Network::send connection, "{!{FC#{msg}\n" end end
    end
    account
  end
end
