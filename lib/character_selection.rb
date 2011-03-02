
class CharacterSelection

  def initialize( account_system )
    raise "account_system not an instance of AccountSystem" unless account_system.kind_of? AccountSystem
    @account_system = account_system
    @selecting = {}
    @selected = []
  end

  def size
    @selecting.size
  end

  def tick
    @selecting.each_value do |character_flow|
      character_flow.resume
    end

    @selecting.delete_if do |account,character_flow|
      Log::info "account #{account.name} completed character selection", "characterselection" if not character_flow.alive?
      not character_flow.alive?
    end
  end

  def select_character( account )
    @selecting[account] = character_flow account
    Log::info "account #{account.name} started selecting char", "characterselection"
  end

  def disconnect( account )
    @selecting.delete account
  end

  def next_char_selection
    @selected.shift
  end

  private
  def character_flow( account )
    Fiber.new do
      char = get_character account
      Log::info "account #{account.name} selected char #{char.name}", "characterselection"
      @selected << { account:account, character:char }
    end
  end

  def get_character( account )
    char = select_character_from_menu account
    char = new_character account unless char
    char
  end

  def select_character_from_menu( account )
    character_menu = [
                      "\n\nSelect a character from account {FC#{account.name}{FY:",
                      [nil, "New Character"],
                     ]
    account.characters.each do |char|
      character_menu.push [char, char.name]
    end
    Util::InFiber::ValueMenu::activate ->(msg){ @account_system.send_msg account, msg + "{@" }, ->{ @account_system.next_command account }, character_menu
  end

  def new_character( account )
    char = nil
    while true
      @account_system.send_msg account, "{!{FYnew character name{FB>{@ "
      char = Character.new({name:Util::InFiber::wait_for_next_command(->{@account_system.next_command account}).capitalize})
      char.account = account
      char.mob = Mob.new({:short_name => char.name, :long_name => "{FGLegionnaire {FY#{char.name}{FG the legendary hero"})
      break if char.save
      char.errors.each_value do |err| err.each do |msg| @account_system.send_msg account, "{!{FC#{msg}{@\n" end end
    end
    char
  end
end
