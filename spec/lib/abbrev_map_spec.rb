require "spec_helper.rb"


#######################################################################################
#  playing around with dynamic example generation, as a form a of model-based testing

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


#### new examples

describe AbbrevMap do


  context "an instance" do
    before :each do
      @map = AbbrevMap.new
    end

    def should_find( key, value, match, rest )
      result = @map.find key
      result[:value].should == value
      result[:match].should == match
      result[:rest].should == rest
    end

    it "raises error if key isn't a string" do
      expect { @map.add 56, 3 }.to raise_error
      expect { @map.add nil, "hay" }.to raise_error
    end

    it "doesn't allow overwrites, uses first key,value added" do
      @map.add "abc def", 5
      @map.add "abc def", 7
      @map.add "abc def q", 8
      should_find "abc def", 5, "abc def", ""
      should_find "a", 5, "a", ""
      should_find "a d q", 8, "a d q", ""
    end

    context "with some nil values on overlapping keys" do
      before :each do
        @pairs = {}
        @pairs["cast acid"] = 5
        @pairs["cast acid blast"] = nil
        @pairs["cast acid blast void"] = 7
        @pairs["cast bloo blast"] = nil
        
        @pairs.each_pair do |key,value|
          @map.add key, value
        end
      end

      it "matches each exact key to its value, and notes the entire match and epsilon remaining" do
        @pairs.each_pair do |key,value|
          should_find key, value, key, ""
        end
      end

      it "matches abbreviations correctly" do
        should_find "cast acid", 5, "cast acid", ""
        should_find "cast acid b", nil, "cast acid b", ""
        should_find "cast acid b zz", nil, "cast acid b", "zz"
        should_find "cast acid b void", 7, "cast acid b void", ""
        should_find "cast b void", nil, "cast b", "void"
      end
    end

    context "with a bunch of overlapping keys" do
      before :each do
        @pairs = {}
        @pairs["cast"] = 0
        @pairs["cast fireball"] = 10
        @pairs["cast fireball room"] = 20
        @pairs["cast fireball rofl"] = 30
        @pairs["cast fireball roft"] = 35
        @pairs["cast fireball root"] = 40
        @pairs["cast fir tree"] = 45
        @pairs["cast fir roomz"] = 50

        @pairs.each_pair do |key,value|
          @map.add key, value
        end
      end

      it "matches each exact key to its value, and notes the entire match and epsilon remaining" do
        @pairs.each_pair do |key,value|
          should_find key, value, key, ""
        end
      end

      it "matches epsilon with nil" do
        @map.find("").should be_nil
      end

      it "matches non-existent with nil" do
        @map.find("quaff").should be_nil
      end

      it "finds nil if first token is mismatched" do
        @map.find("castz").should be_nil
      end

      it "matches abbreviations to the correct value, with the correct match/remaining" do
        should_find( "c", 0, "c", "" )
        should_find( "cast f", 10, "cast f", "" )
        should_find( "cast f zz df", 10, "cast f", "zz df" )
        should_find( "cast fireb zz df", 10, "cast fireb", "zz df" )
        should_find( "cast f r zz df", 20, "cast f r", "zz df" )
        should_find( "cast f roo zz df", 20, "cast f roo", "zz df" )
        should_find( "c fir ro zz df", 20, "c fir ro", "zz df" )
        should_find( "c fire ro", 20, "c fire ro", "" )
        should_find( "c f rof", 30, "c f rof", "" )
        should_find( "c fi rofl", 30, "c fi rofl", "" )
        should_find( "c f rof absdf shockw", 30, "c f rof", "absdf shockw" )
        should_find( "c fi roft", 35, "c fi roft", "" )
        should_find( "c fi roft abc", 35, "c fi roft", "abc" )
        should_find( "c fi root", 40, "c fi root", "" )
        should_find( "cast firebal root", 40, "cast firebal root", "" )
        should_find( "c fi root dqf omg:)", 40, "c fi root", "dqf omg:)" )
        should_find( "c fir tree", 45, "c fir tree", "" )
        should_find( "c fire tree", 10, "c fire", "tree" )
        should_find( "c fir t zzz", 45, "c fir t", "zzz" )
        should_find( "c f t", 45, "c f t", "" )
        should_find( "cast fir room", 20, "cast fir room", "" )
        should_find( "cast fir roomz", 50, "cast fir roomz", "" )
        should_find( "c f roomz abc", 50, "c f roomz", "abc" )
      end

      it "returns a partially mismatched token as part of remaining" do
        should_find( "cast fz", 0, "cast", "fz" )
        should_find( "c fire roi", 10, "c fire", "roi" )
        should_find( "c fzire roi", 0, "c", "fzire roi" )
      end
      
    end # context bunch of overlapping keys
  end # context an instance
end



