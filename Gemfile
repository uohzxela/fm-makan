source "https://rubygems.org"
ruby "2.0.0"
gem 'sinatra'
gem 'rack-flash3'	
gem 'datamapper'


gem 'sinatra-redirect-with-flash'
gem 'builder'
gem 'shotgun'
gem 'dm-migrations'

group :production do
    gem "pg"
    gem "dm-postgres-adapter"
end

group :development, :test do
    gem "sqlite3"
    gem "dm-sqlite-adapter"
end