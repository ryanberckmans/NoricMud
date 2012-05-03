module NoricMud
  class Mob < MudObject
    attr_accessor :room, :char, :hp_max, :hp, :energy_max, :energy, :short_name, :long_name

    def hp_color
      quartile = hp * 1.0 / hp_max
      quartile_color(quartile) + hp.to_s
    end

    def energy_color
      quartile = energy * 1.0 / energy_max
      quartile_color(quartile) + energy.to_s
    end

    def quartile_color quartile
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

    def self.persistence_class
      Persistence::PersistedMob
    end
  end
end
