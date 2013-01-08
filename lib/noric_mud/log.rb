require 'thread'
require 'logger'

class Logger
  class Formatter
    private
    def format_datetime time
      if @datetime_format.nil?
        time.strftime("%a:%Y:%m:%d:%Z:%H:%M:%S") << "\t%10.6f" % time.to_f
      else
        time.strftime(@datetime_format)
      end
    end
  end
end

Logger::Formatter.send :remove_const, :Format
Logger::Formatter.send :const_set, :Format, "%s\t%s\t%d\t%5s\t%s\t%s\n"

module NoricMud
  # A Log class based on Ruby's Logger with two features:
  #  1) log messages are passed in blocks; the blocks are evaluated on the main thread side and are skipped when msg severity is below log level
  #  2) logging is done in a separate thread, one thread per instance
  class Log
    PATH = "log/"
    EXTENSION = ".log"
    ROTATION = "daily"

    def initialize log_device = nil, params = {}
      create_logger log_device, params
      @log_statement_queue = Queue.new
      @shutdown_requested = false
      start_log_thread
    end

    def shutdown
      @shutdown_requested = true
      @log_thread.join
    end

    def fatal progname = nil, &block
      log Logger::FATAL, progname, &block
    end

    def error progname = nil, &block
      log Logger::ERROR, progname, &block
    end

    def fatal progname = nil, &block
      log Logger::WARN, progname, &block
    end

    def info progname = nil, &block
      log Logger::INFO, progname, &block
    end

    def debug progname = nil, &block
      log Logger::DEBUG, progname, &block
    end

    private    
    def log severity, progname
      raise "cannot log after #shutdown" if @shutdown_requested
      return if severity < @logger.level
      return unless block_given?
      @log_statement_queue << { :severity => severity, :msg => yield, :progname => progname }
      nil
    end

    def create_logger log_device = nil, params = {}
      log_device = PATH + log_device + EXTENSION if log_device.is_a? String
      @logger = Logger.new log_device, ROTATION
      raise "failed to initialize logger #{log_device.to_s}" unless @logger
      @logger.level = params[:level] if params[:level]
    end
    
    def start_log_thread
      @log_thread = Thread.new do
        def log_job job
          @logger.log job[:severity], job[:msg], job[:progname]
        end
        begin
          @logger.log Logger::FATAL, "opening log file"
          log_job @log_statement_queue.pop while not @shutdown_requested
          # @shutdown_requested is true, drain the queue and then end the thread
          log_job @log_statement_queue.pop(true) while true rescue nil # pop(true) will raise an error when the queue is empty
        ensure
          @logger.log Logger::FATAL, "closing log file" rescue nil
          @logger.close
        end
      end
      @log_thread.priority = (defined? JRUBY_VERSION) ? 1 : -3 # JRuby threads have priority 1-10, with 10 highest; MRI accepts integer priority; main thread has a default priority of 0
      nil
    end
  end
end
