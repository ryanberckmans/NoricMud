module NoricMud
  module ObjectParts
    module Description
      def description
        return get_attribute :description
      end

      alias_method :desc, :description
      
      def description= new_description
        set_attribute :description, new_description
      end

      alias_method :desc=, :description=
    end
  end
end
