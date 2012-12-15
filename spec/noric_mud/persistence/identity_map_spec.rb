require 'spec_helper'
require 'noric_mud/persistence/identity_map'

module NoricMud
  module Persistence
    describe IdentityMap do
      it { subject[:key_not_found].should be_nil }
      it { expect { subject[:get] = :works }.to change{subject[:get]}.from(nil).to(:works) }
      
      context "with a value set that has a strong reference" do
        before :each do
          @key = :foo
          @value = Object.new
          subject[@key] = @value
          10.times { ObjectSpace.garbage_collect }
        end
        it { subject[@key].should eq(@value) } unless JRUBY_VERSION # cannot force garbage collection in jruby
      end

      context "with a value set that has no strong reference" do
        before :each do
          @key = :foo
          subject[@key] = Object.new
          10.times { ObjectSpace.garbage_collect }
        end
        it { subject[@key].should be_nil } unless JRUBY_VERSION # cannot force garbage collection in jruby
      end
    end
  end
end
