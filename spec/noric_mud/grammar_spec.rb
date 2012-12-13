require 'spec_helper'
require 'noric_mud/object_parts/gender'
require 'noric_mud/grammar'

def it_returns_correct_pronoun gender, pronoun_case
  it "returns correct pronoun for input gender and pronoun_case" do
    NoricMud::Grammar::pronoun(gender, pronoun_case).should eq(NoricMud::Grammar::PRONOUNS[pronoun_case][gender])
  end
end

module NoricMud
  describe Grammar do
    Grammar::PRONOUNS.each_key do |pronoun_case|
      ObjectParts::Gender::GENDERS.each do |gender|
        it_returns_correct_pronoun gender, pronoun_case
      end
    end

    it "returns nil with nil gender" do
      Grammar::pronoun(nil, :nominative).should be_nil
    end

    it "returns nil with nil pronoun_case" do
      Grammar::pronoun(:male, nil).should be_nil
    end
  end
end
