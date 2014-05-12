require 'sinatra'
require 'data_mapper'
require 'rack-flash'
require 'sinatra/redirect_with_flash'
require 'cgi'
 
enable :sessions
use Rack::Flash, :sweep => true

#DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/makan.db")

 configure :development do
    DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/makan.db")
end

configure :production do
    DataMapper.setup(:default, ENV['HEROKU_POSTGRESQL_PURPLE_URL'])
end
 
class MakanSpot
  include DataMapper::Resource
  property :id, Serial
  property :name, Text, :required => true
  property :price, String, :required => true
  property :notes, Text
  property :url, String
  property :address, Text, :required => true
end
 
DataMapper.finalize.auto_upgrade!

helpers do 
	include Rack::Utils
	alias_method :h, :escape_html
end

get '/rss.xml' do
	@spots = MakanSpot.all :order => :id.desc
	builder :rss
end

get '/' do
  @spots = MakanSpot.all :order => :id.desc
  @title = 'All Spots'
  @getColor = lambda do |price|
    if price == "$"
      return "green"
    elsif price == "$$"
      return "orange"
    else 
      return "red"
    end
  end
  if @spots.empty?
  	flash[:error] = 'No spots found. Add your first below.'
  end
  erb :home
end

get '/add' do
  @title = 'Add makan spot'
  erb :add
end

post '/' do
	s = MakanSpot.new
	s.name = params[:name]
	s.price = params[:price]
	s.address = params[:address]
  s.url = prependHttp(CGI.escape(params[:url]))
  s.notes = params[:notes]
 
   	if s.save
        redirect '/', :notice => 'Makan spot created successfully.'
    else
        redirect '/', :error => 'Failed to save makan spot.'
    end
end

get '/filter/:price' do
  @spots = MakanSpot.all :order => :id.desc, :price => params[:price]
  @title = 'All Spots'
  @getColor = lambda do |price|
    if price == "$"
      return "green"
    elsif price == "$$"
      return "orange"
    else 
      return "red"
    end
  end
  if @spots.empty?
    flash[:error] = 'No spots found. Add your first below.'
  end
  erb :home
end

get '/:id' do
	@spot = MakanSpot.get params[:id]
	@title = "Edit makan spot ##{params[:id]}"
	erb :edit
end

put '/:id' do
	s = MakanSpot.get params[:id]
	s.name = params[:name]
	s.price = params[:price]
  s.address = params[:address]
  s.url = prependHttp(params[:url])
  s.notes = params[:notes]
 	if s.save
        redirect '/', :notice => 'Makan spot updated successfully.'
    else
        redirect '/', :error => 'Error updating makan spot.'
    end
end

get '/:id/delete' do
	@spot = MakanSpot.get params[:id]
	@title = "Confirm deletion of makan spot ##{params[:id]}"
	erb :delete
end

delete '/:id' do
	s = MakanSpot.get params[:id]
    if s.destroy
        redirect '/', :notice => 'Makan spot deleted successfully.'
    else
        redirect '/', :error => 'Error deleting makan spot.'
    end
end

def getColor(price)
  if price == "$"
    return "green"
  elsif price == "$$"
    return "orange"
  else 
    return "red"
  end
end

def prependHttp(url)
  if url.downcase.include?("http://") || url.empty?
    url
  else
    url.insert(0, "http://")
  end
end