module NoricMud
  module Grammar
    # Check out rubygems.org/gems/linguistics and gems/english before doing any more work
    
    # Return the grammatical pronoun to use in a particular case, based on the gender of this object.
    # @example
    #   "Noric hits himself." -> "Noric hits #{noric.pronoun :reflexive}"
    #   "Alice wipes her face." -> "Alice wipes her #{alice.pronoun :possessive_adjective}"
    # @param gender - must be one of :male, :female, :it
    # @param pronoun_case - the type of pronoun requested - must be one of :nominative, :objective, :possessive, :possessive_adjective, or :reflexive
    # @return String pronoun 
    def self.pronoun gender, pronoun_case
      return nil if pronoun_case.nil?
      PRONOUNS[pronoun_case][gender]
    end

    PRONOUNS = {
      # Grammar references:
      #  http://www.grammarphobia.com/blog/2010/09/his-and-hers.html
      #  http://grammar.about.com/od/pq/g/posspronterm.htm
      #  http://grammar.ccc.commnet.edu/grammar/cases.htm

      # "Noric/Alice/The Phase Beast's eyes go blank. He/she/it collapses into a heap of dust."
      :nominative => {
        :male => "he",
        :female => "she",
        :it => "it"
      },

      # "Give him/her/it the bloodstone."
      :objective => {
        :male => "him",
        :female => "her",
        :it => "it"
      },

      # "Noric/Alice/The Phase Beast wipes his/her/its face."
      :possessive_adjective => {
        :male => "his",
        :female => "her",
        :it => "its"
      },

      # "The bloodstone is his/hers/its."
      :possessive => {
        :male => "his",
        :female => "hers",
        :it => "its"
      },

      # "Noric/Alice/The Phase Beast slaps himself/herslf/itself."
      :reflexive => {
        :male => "himself",
        :female => "herself",
        :it => "itself"
      }
    }
  end
end
