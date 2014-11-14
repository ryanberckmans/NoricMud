
module NoricMud
  module Commands
    # We borrow (a much more basic) CommandSet from Evennia
    class CommandSet
      # Strategies used in #merge
      UNION = :union
      REPLACE = :replace

      # Guidelines for integer priority
      PRIORITY_REGULAR = 0
      
      def initialize priority, merge_strategy
        @commands = []
        @priority = priority
        @merge_strategy = merge_strategy
      end

      def merge command_set_other
        
      end

      private
      def union
      end

      def replace
      end
    end
  end
end
