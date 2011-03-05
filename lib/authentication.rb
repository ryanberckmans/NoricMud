
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
      break if account.errors[:name].empty?
      account.errors[:name].each do |msg| @network.send connection, "{!{FC#{msg}{@\n" end
    end

    # i.e. account has a valid name, may or may not be a new account
    
    if account.new_record?
      Log::debug "connection #{connection} creating new account #{account.name}", "authentication"
      account = create connection, account
    else
      Log::debug "connection #{connection} authorizing account #{account.name}", "authentication"
      account = authorize connection, account
    end
    account
  end

  def create( connection, account )
    while true
      @network.send connection, "{!{FYenter a password for new account {FC#{account.name}{FB>{@ "
      account.password = Util::InFiber::wait_for_next_command(->{@network.next_command connection})
      break if account.save
      raise "expected no account.name errors" unless account.errors[:name].empty?
      account.errors[:password].each do |msg| @network.send connection, "{!{FC#{msg}{@\n" end
    end
    Log::debug "connection #{connection} finished creating account #{account.name}", "authentication"
    account
  end

  MAX_ATTEMPTS = 2
  def authorize( connection, account )
    attempts = 0
    account = while true
                @network.send connection, "{!{FYpassword for existing account {FC#{account.name}{FB>{@ "
                password_attempt = Util::InFiber::wait_for_next_command(->{@network.next_command connection})
                if password_attempt == account.password
                  Log::debug "connection #{connection} authorized account #{account.name}", "authentication" if account
                  @network.send connection, "{!{FCauthorized.{@\n"
                  break account
                end
                @network.send connection, "{!{FCwrong password.{@\n"
                attempts += 1
                if attempts > MAX_ATTEMPTS
                  @network.send connection, "{!{FYtoo many attempts. {FR:({@\n"
                  Log::debug "connection #{connection} failed to authorize account #{account.name}", "authentication" if not account
                  break nil
                end
              end
    account
  end
end
