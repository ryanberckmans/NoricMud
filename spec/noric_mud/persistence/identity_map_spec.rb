require 'spec_helper'
require 'noric_mud/persistence/identity_map'

module NoricMud
  module Persistence
    describe IdentityMap do
      it { subject.set_object(:return_value_nil, Object.new).should be_nil }
      it { subject.get_object(:key_not_found).should be_nil }
      it { expect { subject.set_object(:get, :works) }.to change{subject.get_object :get}.from(nil).to(:works) }
      
      context "with a value set that has a strong reference" do
        before :each do
          @key = :foo
          @value = Object.new
          subject.set_object @key, @value
          10.times { ObjectSpace.garbage_collect }
        end
        it { subject.get_object(@key).should eq(@value) } unless JRUBY_VERSION # cannot force garbage collection in jruby
      end

      context "with a value set that has no strong reference" do
        before :each do
          @key = :foo
          subject.set_object @key, Object.new
          10.times { ObjectSpace.garbage_collect }
        end
        it { subject.get_object(@key).should be_nil } unless JRUBY_VERSION # cannot force garbage collection in jruby
      end
    end
  end
end
