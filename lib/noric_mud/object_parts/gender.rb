module NoricMud
  module ObjectParts
    module Gender
      GENDERS = [:male,:female,:it]

      def gender
        get_attribute :gender
      end

      # Set the gender for this object
      # @param new_gender - must be one of :male, :female, :it
      # @return nil
      def gender= new_gender
        raise "new gender must be one of #{GENDERS.to_s}" unless GENDERS.include? new_gender
        set_attribute :gender, new_gender
      end
    end
  end
end
