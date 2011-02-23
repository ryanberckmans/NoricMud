module Game
  @rooms = Room.find

  def self.tick
    Log::debug "start tick", "game"
    Account::new_logons.each do |char| logon char end
    Log::debug "end tick", "game"
  end

  private
  def self.logon( char )
    Log::info "logging on #{char.name}", "game"
    Connection::send char.connection, "Logged on!\n"
  end
end
