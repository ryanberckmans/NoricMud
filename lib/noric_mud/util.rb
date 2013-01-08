require 'strscan'

module NoricMud
  module Util
    class << self
      def md5( o )
        Digest::MD5.hexdigest(o)
      end

      def log_exception( severity, e, progname = nil )
        Log::log severity, "uncaught exception #{e.class}", progname
        Log::log severity, "exception ancestors: " + e.class.ancestors.join("\t"), progname
        Log::log severity, e.backtrace.join("\t"), progname
        Log::log severity, e.message, progname if e.message.length > 0
      end

      LINE_WRAP = 79
      def justify( string, line_length=LINE_WRAP )
        return string if string.length < line_length
        string.gsub! "\n", " "
        s = StringScanner.new string
        s.scan /.{1,#{line_length}}\s/
        return s.matched + "\n" + justify(s.rest, line_length)
      end

      def strip_newlines( string )
        string.gsub /\r?\n/, ", "
      end

    end # class << self

    module InFiber
      def self.wait_for_next_command( next_command_function )
        cmd = nil
        while not cmd
          Fiber.yield
          cmd = next_command_function.()
        end
        Log::debug "Util::InFiber::wait_for_next_command got (#{cmd})", "util"
        cmd
      end

      module ValueMenu
        def self.activate( send_function, next_command_function, menu_items, alphabetic_index = false )
          # where menu_items is an array, and each element of menu_items is one of:
          #  string - a line of text (header) to be displayed literally in the menu
          #  (value, string) - a value the user can select, represented by the label string
          # the items are processed in order, to generate an ordered menu

          menu = "{@{!"
          menu_index = 1
          menu_options = {}

          menu_items.each do |item|
            if item.kind_of? String
              menu += "{FY" + item + "\n"
            elsif item.kind_of? Array
              item_index = alphabetic_index ? (96+menu_index).chr : menu_index
              menu += " {FC#{item_index}{FG) - {FU#{item[1]}\n"
              menu_options[item_index.to_s] = item[0]
              menu_index += 1
            end
          end

          while true
            send_function.(menu)
            selection = InFiber::wait_for_next_command next_command_function
            break if menu_options.key? selection
          end
          menu_options[selection]
        end #  self.activate
      end # module ValueMenu
    end # module Infiber
  end
end
