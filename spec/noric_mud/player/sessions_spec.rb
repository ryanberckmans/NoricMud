require 'spec_helper'

require 'noric_mud/player/sessions'

module NoricMud
  module Player
    describe Sessions do
      before :each do
        @server = double "Server"
      end
      subject { Sessions.new @server }
    end
  end
end
