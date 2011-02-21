require Util::here 'server.rb'

module Connections
  @server = Connections::Server.new
  
  def self.tick
    @server.tick
  end

  Log::info "initialized", "connections"
end


