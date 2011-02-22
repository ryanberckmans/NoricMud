module Util
  def self.md5( o )
    Digest::MD5.hexdigest(o)
  end

  def self.here( string )
    File.expand_path(File.join(File.dirname(caller[0].split(":")[0]), string))
  end

  def self.strip_newlines( string )
    string.gsub /\r?\n/, ", "
  end

  def self.resumption_exception(*args)
    # from internet
    raise *args
  rescue Exception => e
    callcc do |cc|
      scls = class << e; self; end
      scls.send(:define_method, :resume, lambda { cc.call })
      raise
    end
  end

  module InFiber
    def self.wait_for_next_command( conn_id )
      cmd = nil
      while not cmd
        Fiber.yield
        cmd = Connections::next_command conn_id
      end
      cmd
    end

    module ValueMenu
      def self.activate( conn_id, menu_items, alphabetic_index = false )
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
          Connections::send conn_id, menu
          selection = InFiber::wait_for_next_command conn_id
          break if menu_options.key? selection
        end
        menu_options[selection]
      end #  self.activate
    end # module ValueMenu

  end
end
