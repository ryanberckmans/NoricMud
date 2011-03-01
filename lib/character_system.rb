require Util.here "character_selection.rb"

class CharacterSystem

  def initialize( account_system, character_selection )
    raise "account_system not an instance of AccountSystem" unless account_system.kind_of? AccountSystem
    raise "character_selection not an instance of CharacterSelection" unless character_selection.kind_of? CharacterSelection
    @account_system = account_system
    @character_selection = character_selection
    @characters_online = {}
    @new_character_connections = []
    @new_character_disconnections = []
  end

  def tick
    process_new_account_disconnections
    process_new_account_connections
    process_accounts_selecting_character
  end
  
  def next_character_connection
    @new_character_connections.shift
  end

  def next_character_disconnection
    @new_character_disconnections.shift
  end

  def next_command( char )
    verify_online char
    @account_system.next_command @characters_online[char]
  end

  def disconnect( char )
    @account_system.disconnect @characters_online[char]
    set_offline char
  end

  def send_msg( char, msg )
    verify_online char
    @account_system.send_msg @characters_online[char], msg
  end

  private

  def verify_online( char )
    raise "expected #{char.name} to be online" unless @characters_online.key? char
  end
  
  def verify_offline( char )
    raise "expected #{char.name} to be offline" if @characters_online.key? char
  end
  
  def process_new_account_connections
    @account_system.new_connections.each do |account|
      Log::info "account #{account.name} connected, selecting character", "characterlogins"
      @accounts_selecting_character[ account ] = character_flow account
    end
  end

  def process_new_account_disconnections
    @account_system.new_disconnections.each do |account|
      if @accounts_selecting_character.key? account
        @accounts_selecting_character.delete account
        Log::info "account #{account.name} disconnected, was currently selecting character", "characterlogins"
      elsif @characters_online.value? account
        char = @characters_online.key(account)
        Log::info "account #{account.name} disconnected, character #{char.name}", "characterlogins"
        @new_character_disconnections << char
        set_offline char
      else
        raise "disconnected account #{account.name} not found in system", "characterlogins"
      end
    end
  end

  def process_accounts_selecting_character
    @accounts_selecting_character.each_value do |character_flow|
      character_flow.resume
    end

    @accounts_selecting_character.delete_if do |account,character_flow|
      Log::info "account #{account.name} completed character flow", "characterlogins" if not character_flow.alive?
      not character_flow.alive?
    end
  end

  def set_online( char, account )
    verify_offline char
    Log::info "character #{char.name}, account #{account.name} set online", "characterlogins"
    @characters_online[char] = account
    @new_character_connections << char
  end

  def set_offline( char )
    verify_online char
    Log::info "character #{char.name}, account #{@characters_online[char].name} set offline", "characterlogins"
    @characters_online.delete char
  end
end
