source 'http://rubygems.org'

gem "rails", "~> 3.2.3"
gem 'seh'
gem 'depq'

group :no_jruby do
  gem "sqlite3-ruby", "~> 1.3.3", :require => 'sqlite3'
end

group :jruby do
  gem "activerecord-jdbcsqlite3-adapter", "~> 1.2.2.1"
end

group :development do
  gem "rspec", "~> 2.12.0"
end

group :profile do
  gem "ruby-prof", "~> 0.11.2"
end
