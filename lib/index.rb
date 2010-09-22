require 'rubygems'
require 'sinatra'
require 'datamapper'

configure do
  DataMapper.setup(:default, 'sqlite3::memory:')
  class Project
    include DataMapper::Resource
    
    property :mid, Serial
    property :name, String
    property :desc, String
    property :long_desc, String
    property :submitter, String
    property :probs_techs,String
    property :rank, Integer
    property :created_at, DateTime
    
    property :is_deleted, Boolean, :default=>false
    property :is_implemented, Boolean, :default=>false
  end
  DataMapper.auto_upgrade!
end

get '/' do
  erb :index
end

post '/' do
  p = params['post']
  Project.new(:name=>p['project_name'],:desc=>p['desc'],:long_desc=>p['long_desc'],:probs_techs=>p['probs_techs'],:submitter=>p['submitter']).save
  redirect '/'
end