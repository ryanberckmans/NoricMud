module NoricMud
  module ObjectParts
    module LongName
      def long_name
        return get_attribute :long_name
      end
      
      def long_name= new_long_name
        set_attribute :long_name, new_long_name
      end
    end
  end
end
