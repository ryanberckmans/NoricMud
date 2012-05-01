require 'thread'
require 'logger'

class Logger
  class Formatter
    private
    def format_datetime(time)
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

class Log
  PATH = "log/"
  EXTENSION = ".log"
  ROTATION = "daily"
  @@log_statement_queue = Queue.new

  def self.log_thread_start
    raise "call log_thread_start only once" if defined? @@log_threads
    @@log_threads = []
    10.times do
      log_thread = Thread.new { @@log_statement_queue.pop.call while true }
      log_thread.priority = -2
      @@log_threads << log_thread
    end
    nil
  end

  def self.fatal( msg, progname = nil )
    log Logger::FATAL, msg, progname
  end

  def self.error( msg, progname = nil )
    log Logger::ERROR, msg, progname
  end

  def self.warn( msg, progname = nil )
    log Logger::WARN, msg, progname
  end

  def self.info( msg, progname = nil )
    log Logger::INFO, msg, progname
  end

  def self.debug( msg, progname = nil )
    log Logger::DEBUG, msg, progname
  end
  
  def self.log( sev, msg, progname = nil )
    raise "tried to log a msg to the default logger, but the default logger has not yet been set" unless defined? @@default
    @@log_statement_queue.push lambda { @@default.log sev, msg, progname }
    nil
  end
  
  def self.get( logdev = nil, params = {} )
    if not logdev
      raise "tried to return the default logger, but the default logger has not yet been set" unless defined? @@default
      return @@default
    end
    @@loggers ||= {}
    if not @@loggers[ logdev ]
      logdev = PATH + logdev + EXTENSION if logdev.is_a? String
      @@loggers[logdev] = Logger.new logdev, ROTATION
      raise "failed to initialize logger #{logdev.to_s}" unless @@loggers[logdev]
      @@loggers[logdev].level = params[:level] if params[:level]
      @@loggers[logdev].log Logger::INFO, "opening log file"
    end
    @@default = @@loggers[ logdev ] if params[:default]
    @@loggers[ logdev ]
  end

  def self.close_all
    @@loggers.each_value { |log| log.log Logger::INFO, "closing log file" rescue nil; log.close rescue nil } if defined? @@loggers
  end
end

at_exit { Log::close_all }
