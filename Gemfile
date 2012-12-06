source 'http://rubygems.org'

gem "rails", "~> 3.2.3"
gem 'seh'
gem 'depq'

group :non_jruby do
  gem 'sqlite3-ruby', :require => 'sqlite3'
end

group :jruby do
  gem 'jdbc-sqlite3'
end

group :development, :test do
  gem 'rspec'
end

group :profile do
  gem 'ruby-prof'
end
