require 'spec_helper'
require 'noric_mud/persistence/identity_map'

module NoricMud
  module Persistence
    describe IdentityMap do
      it "raises error when constructing a new IdentityMap, because it's a singleton" do
        expect { IdentityMap.new }.to raise_error
      end
    end
  end
end
