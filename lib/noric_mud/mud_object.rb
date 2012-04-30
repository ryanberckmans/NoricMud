module NoricMud
  class MudObject
    def initialize persistence=nil
      @persistence = persistence
    end

    def save
      @persistence.async_save self if @persistence
    end

    def persist?
      !@persistence.nil?
    end
  end
end
