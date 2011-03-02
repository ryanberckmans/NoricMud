
class Authentication

  def initialize( network )
    raise "network not an instance of Network" unless network.kind_of? Network
    @network = network
    @authenticating = {}
    @auth_fails = []
    @auth_successes = []
  end

  def size
    @authenticating.size
  end

  def tick
    @authenticating.each_value do |account_flow|
      account_flow.resume
    end

    @authenticating.delete_if do |connection,account_flow|
      Log::info "connections #{connection} completed account flow", "authentication" if not account_flow.alive?
      not account_flow.alive?
    end
  end

  def authenticate( connection )
    @authenticating[connection] = account_auth_flow connection
  end

  def disconnect( connection )
    @authenticating.delete connection
  end

  def next_auth_fail
    @auth_fails.shift
  end

  def next_auth_success
    @auth_successes.shift
  end

  private
  def account_auth_flow( connection )
    Fiber.new do
      account = get_account connection
      if account
        @auth_successes << { connection:connection, account:account }
        Log::info "connection #{connection} successfully authenticated as #{account.name}", "authentication"
      else
        @auth_fails << connection
        Log::info "connection #{connection} failed to authenticate", "authentication"
      end
    end
  end

  def get_account( connection )
    account = nil
    while true
      @network.send connection, "{!{FYaccount name{FB>{@ "
      account = Account.find_or_initialize_by_name(Util::InFiber::wait_for_next_command(->{@network.next_command connection}).downcase)
      break unless account.new_record?
      break if account.save
      account.errors.each_value do |err| err.each do |msg| @network.send connection, "{!{FC#{msg}{@\n" end end
    end
    account
  end
end
