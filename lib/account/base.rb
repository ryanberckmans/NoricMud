
module Login
  @connections = {}
  @new_logins = []

  SPLASH = <<eos
{@{!{FG     ________             ________ \r\n{FG    / ____  /\\           /\\  ____ \\ \r\n{FG   / /\\__/ / _\\_________/_ \\ \\__/\\ \\ \r\n{FG  / /_/_/ / /             \\ \\ \\_\\_\\ \\ \r\n{FG /_______/ /_______________\\ \\_______\\ \r\n{FG \\  ____ \\ \\               / / ____  / \r\n{FG  \\ \\ \\_\\ \\ \\_____________/ / /_/ / / \r\n{FG   \\ \\/__\\ \\  /{FR N O T A{FG \\  / /__\\/ / \r\n{FG    \\_______\\/{FY M   U   D{FG \\/_______/ \r\n{FG  \r\n       {FW+ {FRC a t a l y s t i c a {FW+{@ \r\n \r\n
eos

  def self.tick
    @new_logons.clear
    
    Connection::new_connections.each do |connection|
      Log::info "socket #{connection} started new account flow", "accounts"
      @connections[ connection ] = account_flow connection
    end

    Connection::new_disconnections.each do |connection|
      Log::info "socket #{connection} disconnected, deleting from connections", "accounts"
      @connections.delete connection
    end

    @connections.each_value do |account_flow|
      account_flow.resume
    end

    @connections.delete_if do |connection,account_flow|
      Log::info "socket #{connection} completed account flow, deleting from connections", "accounts"
      not account_flow.alive?
    end
  end

  def self.new_logins
    @new_logins
  end

  private

  def self.account_flow( id )
    Fiber.new do
      connection = id
      Connection::send connection, SPLASH

      account = get_account connection
      Log::info "socket #{id} using account #{account.name}", "accounts"

      char = get_character account
      Log::info "account #{account.name} selected char #{char.name}", "accounts"

      @new_logons << char
      Connection::send connection, "{!{FYLogging on {FU#{char.name}{FY...\n"
      Log::info "account #{account.name} with character #{char.name} registered to log on", "accounts"
    end
  end

  def self.get_account( connection )
    account = nil
    while true
      Connection::send connection, "{!{FYaccount name{FB> "
      account = Account.find_or_initialize_by_name(Util::InFiber::wait_for_next_command( connection ))
      break unless account.new_record?
      break if account.save
      account.errors.each_value do |err| err.each do |msg| Connection::send connection, "{!{FC#{msg}\n" end end
    end
    account.connection = connection
    account
  end

  def self.get_character( account )
    char = select_character account
    char = new_character account unless char
    char.connection = account.connection
    char
  end
  
  def self.select_character( account )
    character_menu = [
                      "\n\nSelect a character from account {FC#{account.name}{FY:",
                      [nil, "New Character"],
                     ]
    account.characters.each do |char|
      character_menu.push [char, char.name]
    end
    Util::InFiber::ValueMenu::activate account.connection, character_menu
  end

  def self.new_character( account )
    char = nil
    while true
      Connection::send account.connection, "{!{FYnew character name{FB> "
      char = Character.find_or_initialize_by_name(Util::InFiber::wait_for_next_command( account.connection ).capitalize)
      break unless char.new_record?
      char.account = account
      char.mob = Mob.new({:short_name => char.name, :long_name => "The legendary hero known as #{char.name}"})
      break if char.save
      char.errors.each_value do |err| err.each do |msg| Connection::send account.connection, "{!{FC#{msg}\n" end end
    end
    char
  end
end
