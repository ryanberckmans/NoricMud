
module CharacterLoginSystem
  @characters_online = {}
  @accounts_selecting_character = {}
  @new_connections = []
  @new_disconnections = []

  def self.tick
    @new_connections.clear
    @new_disconnections.clear
    process_new_account_disconnections
    process_new_account_connections
    process_accounts_selecting_character
  end
  
  def self.new_connections
    @new_connections
  end


  def self.new_disconnections
    @new_disconnections
  end

  def self.next_command( char )
    verify_online char
    AccountSystem::next_command @characters_online[char]
  end

  def self.disconnect( char )
    AccountSystem::disconnect @characters_online[char]
    set_offline char
  end

  def self.send_msg( char, msg )
    verify_online char
    AccountSystem::send @characters_online[char], msg
  end

  private

  def self.verify_online( char )
    raise "expected #{char.name} to be online" unless @characters_online.key? char
  end
  
  def self.verify_offline( char )
    raise "expected #{char.name} to be offline" if @characters_online.key? char
  end
  
  def self.process_new_account_connections
    AccountSystem::new_connections.each do |account|
      Log::info "account #{account.name} connected, selecting character", "characterlogins"
      @accounts_selecting_character[ account ] = character_flow account
    end
  end

  def self.process_new_account_disconnections
    AccountSystem::new_disconnections.each do |account|
      if @accounts_selecting_character.key? account
        @accounts_selecting_character.delete account
        Log::info "account #{account.name} disconnected, was currently selecting character", "characterlogins"
      elsif @characters_online.value? account
        char = @characters_online.key(account)
        Log::info "account #{account.name} disconnected, character #{char.name}", "characterlogins"
        @new_disconnections << char
        set_offline char
      else
        raise "disconnected account #{account.name} not found in system", "characterlogins"
      end
    end
  end

  def self.process_accounts_selecting_character
    @accounts_selecting_character.each_value do |character_flow|
      character_flow.resume
    end

    @accounts_selecting_character.delete_if do |account,character_flow|
      Log::info "account #{account.name} completed character flow", "characterlogins" if not character_flow.alive?
      not character_flow.alive?
    end
  end

  def self.set_online( char, account )
    verify_offline char
    Log::info "character #{char.name}, account #{account.name} set online", "characterlogins"
    @characters_online[char] = account
    @new_connections << char
  end

  def self.set_offline( char )
    verify_online char
    Log::info "character #{char.name}, account #{@characters_online[char].name} set offline", "characterlogins"
    @characters_online.delete char
  end

  def self.character_flow( account )
    Fiber.new do
      char = get_character account
      Log::info "account #{account.name} selected char #{char.name}, logging on", "characterlogins"
      AccountSystem::send account, "{!{FYLogging on {FU#{char.name}{FY...\n"
      set_online char, account
    end
  end

  def self.get_character( account )
    char = select_character account
    char = new_character account unless char
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
    Util::InFiber::ValueMenu::activate ->(msg){ AccountSystem::send account, msg }, ->{ AccountSystem::next_command account }, character_menu
  end

  def self.new_character( account )
    char = nil
    while true
      AccountSystem::send account, "{!{FYnew character name{FB> "
      char = Character.find_or_initialize_by_name(Util::InFiber::wait_for_next_command(->{AccountSystem::next_command  account}).capitalize)
      break unless char.new_record?
      char.account = account
      char.mob = Mob.new({:short_name => char.name, :long_name => "{FGLegionnaire {FY#{char.name}{FG the legendary hero"})
      break if char.save
      char.errors.each_value do |err| err.each do |msg| AccountSystem::send account, "{!{FC#{msg}\n" end end
    end
    char
  end
end
