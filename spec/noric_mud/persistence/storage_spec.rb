require 'spec_helper'
require 'noric_mud/persistence/storage'

module NoricMud
  module Persistence
    describe Storage do
      params = { :database => :world }
      
      it { expect { Storage::set_attribute({ :persistence_id => 3930483, :name => :valid, :value => "valid"}.merge params) }.to raise_error }
    end
  end
end
