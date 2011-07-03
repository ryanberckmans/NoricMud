class Mob < ActiveRecord::Base
  validates_presence_of :short_name, :long_name

  attr_accessor :room, :char, :hp_max, :hp, :energy_max, :energy, :attack_cooldown, :god, :state

  after_initialize :on_load
  after_find :on_load

  def on_load
    self.hp_max = 250
    self.energy_max = 100
    self.hp = 250
    self.energy = 100
    self.attack_cooldown = 0.0
    self.god = false
    self.state = nil
  end

  CONDITION_DEATH_TEXT = "is dead."
  CONDITION_MAX_HP_TEXT = "is in excellent condition."
  CONDITION_PERCENT_TEXT = {
    0.0 => "barely clings to life.",
    8.0 => "pales visibly as death nears.",
    15.0 => "is covered with blood from oozing wounds.",
    22.0 => "has many grievous wounds.",
    29.0 => "looks pretty awful.",
    36.0 => "has some large, gaping wounds.",
    41.0 => "has some nasty wounds and bleeding cuts.",
    48.0 => "grimaces with pain.",
    55.0 => "has quite a few wounds.",
    62.0 => "winces in pain.",
    69.0 => "has some minor wounds.",
    76.0 => "has some small wounds and bruises.",
    83.0 => "has a nasty looking welt on the forehead.",
    90.0 => "has a few scratches.",
  }

  def dead?
    state == PhysicalState::Dead
  end

  def condition
    if hp == 0
      label = CONDITION_DEATH_TEXT
    elsif hp == hp_max
      label = CONDITION_MAX_HP_TEXT
    else
      percent = hp * 100.0 / hp_max
      CONDITION_PERCENT_TEXT.each_pair do |min_amount,text|
        label = text if percent > min_amount
      end
    end
    short_name + " " + label
  end

  def hp_color
    quartile = hp * 1.0 / hp_max
    quartile_color(quartile) + hp.to_s
  end

  def energy_color
    quartile = energy * 1.0 / energy_max
    quartile_color(quartile) + energy.to_s
  end

  def quartile_color( quartile)
    if quartile < 0.25
      "{FR"
    elsif quartile < 0.5
      "{FY"
    elsif quartile < 0.75
      "{FG"
    else
      "{FU"
    end
  end

  include Seh::EventTarget
  attr_accessor :parents_proc
  def parents
    self.parents_proc.call
  end
  attr_accessor :resting_damage_handler, :meditating_damage_handler # one of ugliest hacks in mud; physicalstate handlers have no place in Mob; to get rid: i) Seh named handlers; ii) instanced physicalstates, or lambda transitions
end
