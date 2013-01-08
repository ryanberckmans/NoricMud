require 'spec_helper'
require 'noric_mud/persistence/util'

module NoricMud
  module Persistence
    describe Util do
      it "serialize passes the data to Marshal.dump" do
        data = [1,2,3]
        Marshal.should_receive(:dump).once.with(data)
        subject.send :serialize, data
      end

      it "serialize returns the data provided by Marshal.dump" do
        result = [1,2,3,4]
        Marshal.should_receive(:dump).once.and_return(result)
        subject.send(:serialize, "data").should eq(result)
      end

      it "deserialize passes the data to Marshal.load" do
        data = [1,2,3]
        Marshal.should_receive(:load).once.with(data)
        subject.send :deserialize, data
      end

      it "deserialize returns the data provided by Marshal.load" do
        result = [1,2,3,4]
        Marshal.should_receive(:load).once.and_return(result)
        subject.send(:deserialize, "data").should eq(result)
      end
    end
  end
end
