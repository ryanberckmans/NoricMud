
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

  def self.account_flow( id )
    Fiber.new do
      conn_id = id
      Connections::send conn_id, SPLASH

      account = get_account conn_id
      Log::info "socket #{id} using account #{account.name}", "accounts"
      Connections::send conn_id, "{!{FCUsing account {FY#{account.name}{FC.\n"

      char = get_character account
      Log::info "account #{account.name} selected char #{char.name}", "accounts"
      Connections::send conn_id, "{!{FCUsing character {FY#{char.name}{FC.\n"
      
      Connections::disconnect conn_id
    end
  end

  def self.get_account( conn_id )
    account = nil
    while true
      Connections::send conn_id, "{!{FYaccount name{FB> "
      account = Account.find_or_initialize_by_name(Util::InFiber::wait_for_next_command( conn_id ))
      break unless account.new_record?
      break if account.save
      account.errors.each_value do |err| err.each do |msg| Connections::send conn_id, "{!{FC#{msg}\n" end end
    end
    account.conn_id = conn_id
    account
  end

  def self.get_character( account )
    char = select_character account
    char = new_character account unless char
    char
  end
  
  def self.select_character( account )
    character_menu = [
                      "\nSelect a character:",
                      [nil, "New Character"],
                     ]
    account.characters.each do |char|
      character_menu.push [char, char.name]
    end
    Util::InFiber::ValueMenu::activate account.conn_id, character_menu
  end

  def self.new_character( account )
    char = nil
    while true
      Connections::send account.conn_id, "{!{FYnew character name{FB> "
      char = Character.find_or_initialize_by_name(Util::InFiber::wait_for_next_command( account.conn_id ).capitalize)
      break unless char.new_record?
      char.account = account
      char.mob = Mob.new({:short_name => char.name, :long_name => "The legendary hero known as #{char.name}"})
      break if char.save
      char.errors.each_value do |err| err.each do |msg| Connections::send account.conn_id, "{!{FC#{msg}\n" end end
    end
    char
  end
end
