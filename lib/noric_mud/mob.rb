require_relative 'object'
require_relative 'object_parts/short_name'
require_relative 'object_parts/long_name'
require_relative 'object_parts/description'
require_relative 'object_parts/gender'

module NoricMud
  class Mob < Object
    include ObjectParts::ShortName
    include ObjectParts::LongName
    include ObjectParts::Description
    include ObjectParts::Gender

    def initialize params={}
      super
      @lost_link = false
      @has_session = false
    end
    
    # Short appearance is used when Mob is seen a room
    def short_appearance
      "{!{FY#{long_name} {FGis here.#{@lost_link ? " [Lost Link]" : ""}\n"
    end

    # Long appearance is used when Mob is looked at
    def long_appearance
      # How Med does it:
      #  description
      #  glance
      #  eq
      #  inventory
      "{!{FG#{description}\n\n{FY{#{short_name} is in excellent condition."
    end

    # Run a cmd from the point of view of this Mob
    def run_cmd cmd
      msg { "Darn, you can't run commands yet" }
    end

    attr_accessor :msg_mailbox # a proc taking |msg| responsible for delivering the msg, set externally

    def lost_link?
      @lost_link
    end

    def lost_link= lost_link
      @lost_link = lost_link
    end

    def has_session?
      @has_session
    end

    def has_session= has_session
      @has_session = has_session
    end
    
    def msg &block
      return unless @has_session
      msg_mailbox.call yield if block_given?
      nil
    end
  end
end
