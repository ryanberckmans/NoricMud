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

  def size
    @characters_online.size
  end

  def online?( char )
    @characters_online.key? char
  end
  
  def connected?( char )
    verify_online char
    @characters_online[char][:connected]
  end

  def char_online_with_account( account )
    @characters_online.each_pair do |char,data|
      return char if data[:account] == account
    end
    nil
  end
  
  def tick
    process_new_account_disconnections
    process_new_account_connections
    process_character_selections
  end
  
  def next_character_connection
    @new_character_connections.shift
  end

  def next_character_disconnection
    @new_character_disconnections.shift
  end

  def next_command( char )
    verify_connected char
    @account_system.next_command @characters_online[char][:account]
  end

  def disconnect( char )
    verify_online char
    @account_system.disconnect @characters_online[char][:account] if connected? char
    set_offline char
  end

  def send_msg( char, msg )
    verify_connected char
    @account_system.send_msg @characters_online[char][:account], msg
  end

  private
  def verify_online( char )
    raise "expected #{char.name} to be online" unless online? char
  end
  
  def verify_offline( char )
    raise "expected #{char.name} to be offline" if online? char
  end

  def verify_connected( char )
    raise "expected #{char.name} to be connected" unless connected? char
  end

  def verify_disconnected( char )
    raise "expected #{char.name} to be disconnected" if connected? char
  end
  
  def process_new_account_connections
    while account = @account_system.next_account_connection do
      raise "account should not be nil" unless account
      if char = char_online_with_account( account )
        set_connected char
      else
        @character_selection.select_character account
      end
    end
  end

  def process_new_account_disconnections
    while account = @account_system.next_account_disconnection do
      raise "account should not be nil" unless account
      @character_selection.disconnect account
      if char = char_online_with_account( account )
        set_disconnected char
      end
    end
  end

  def process_character_selections
    @character_selection.tick
    while pair = @character_selection.next_char_selection do
      raise "char/account should not be nil" unless pair
      set_online pair[:character], pair[:account]
      set_connected pair[:character]
    end
  end

  def set_online( char, account )
    verify_offline char
    Log::info "character #{char.name}, account #{account.name} set online", "charactersystem"
    @characters_online[char] = {account:account} 
  end

  def set_offline( char )
    verify_online char
    Log::info "character #{char.name}, account #{@characters_online[char][:account].name} set offline", "charactersystem"
    @characters_online.delete char
  end

  def set_disconnected( char )
    verify_online char
    verify_connected char
    @characters_online[char][:connected] = false
    @new_character_disconnections << char
    Log::info "character #{char.name}, account #{@characters_online[char][:account].name} set disconnected", "charactersystem"
  end

  def set_connected( char )
    verify_online char
    verify_disconnected char
    @characters_online[char][:connected] = true
    @new_character_connections << char
    Log::info "character #{char.name}, account #{@characters_online[char][:account].name} set connected", "charactersystem"
  end
end
