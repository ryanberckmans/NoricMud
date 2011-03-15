class Mob < ActiveRecord::Base
  validates_presence_of :short_name, :long_name

  attr_accessor :room, :char, :hp_max, :hp, :energy_max, :energy, :attack_cooldown, :god

  after_initialize :on_load

  def on_load
    self.hp_max = 250
    self.energy_max = 100
    self.hp = 250
    self.energy = 100
    self.attack_cooldown = 0.0
    self.god = false
  end

  def condition
    "#{short_name} has #{hp.to_s}/#{hp_max.to_s}hp."
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
end
