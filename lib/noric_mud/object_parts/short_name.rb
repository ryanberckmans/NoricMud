module NoricMud
  module ObjectParts
    module ShortName
      def short_name
        return get_attribute :short_name
      end
      
      def short_name= new_short_name
        set_attribute :short_name, new_short_name
      end
    end
  end
end
