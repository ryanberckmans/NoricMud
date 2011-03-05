require "spec_helper.rb"

shared_examples_for "maps to correct value" do
  subject { @map.find @key }
  it { should satisfy { subject == @value || subject[:value] == @value } }
end

shared_examples_for "for each key,value" do
  before :each do
    @key = @keys.pop
    @value = @values.pop
    @map.add @key, @value
  end
  $size.times do it_behaves_like "maps to correct value" end
end

shared_examples_for "any" do
  context "with nil key" do
    validate_pair nil, nil
  end

  context "with epsilon key" do
    validate_pair "", nil
  end
end

shared_examples_for "for specific key,value, find ignores key whitespace" do
  # input: @key, @value
  # convert to @keys, @values, where each @keys is @key with different whitespace attached
end

def validate_pair( key, value )
  before { @key = key; @value = value }
  it_behaves_like "maps to correct value"
end

def validate_pairs( keys, values )
  before :all do @keys = keys; @values = values end
  $size = keys.size
  it_behaves_like "for each key,value"
end

describe "abbrevmap" do
  before :each do @map = AbbrevMap::new end

  it_behaves_like "any"

  context "handle whitespace" do
    keys = ["     a", "b      ", "\t\t   c", "\t   d   \tq\t", "e e eddd \t\tdqsd"]
    values = ["a", "b", "c", "d", "e"]
    validate_pairs keys, values
  end


  context "with one pair in the map" do
    context do
      def self.expand_strings( strings )
        new_strings = []
        strings.each do |s|
          new_strings << s.succ
          new_strings << s + " a"
        end
        new_strings
      end

      max = 3
      strings = [["a"]]
      max.times { strings << expand_strings( strings[-1]) }
      strings.flatten!
      before :all do
        @value = 2
        @strings = strings
        @strings.flatten!
      end

      before :each do
        @key = @strings.pop
        @map.add @key, @value
      end
      
      # (strings.size).times do it_behaves_like "maps to correct value" end

      after :all do
        @strings.size.should == 0
      end
    end
  end # one pair in map

  # kinds of whitespace
  # case insensitive
  # double add
end

