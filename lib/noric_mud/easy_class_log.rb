require_relative 'log'

module NoricMud
  # EasyClassLog annotates log messages with the class name
  module EasyClassLog
    def fatal &block
      Log::fatal self.class.name, &block
    end

    def error &block
      Log::error self.class.name, &block
    end

    def warn &block
      Log::warn self.class.name, &block
    end

    def info &block
      Log::info self.class.name, &block
    end

    def debug &block
      Log::debug self.class.name, &block
    end
  end
end
