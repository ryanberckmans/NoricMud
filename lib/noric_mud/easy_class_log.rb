require_relative 'log'

module NoricMud
  # EasyClassLog annotates log messages with the class name
  module EasyClassLog
    if self.is_a? Module
      def easy_class_log_name
        name
      end
    else
      def easy_class_log_name
        self.class.name
      end
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
