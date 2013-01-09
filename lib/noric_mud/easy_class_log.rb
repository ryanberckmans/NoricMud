require_relative 'log'

module NoricMud
  # EasyClassLog annotates log messages with the class name
  module EasyClassLog
    def easy_class_log_name
      (defined? name) ? name : self.class.name
    end
    
    def fatal &block
      Log::fatal easy_class_log_name, &block
    end

    def error &block
      Log::error easy_class_log_name, &block
    end

    def warn &block
      Log::warn easy_class_log_name, &block
    end

    def info &block
      Log::info easy_class_log_name, &block
    end

    def debug &block
      Log::debug easy_class_log_name, &block
    end
  end
end
