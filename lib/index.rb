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
    
    def self.list_pending
      all(:is_deleted => false, :is_implemented =>false, :rank.gt => 1)
    end
    def self.count_pending
      count(:is_deleted => false, :is_implemented =>false)
    end
    def self.list_implemented
      all(:is_deleted => false, :is_implemented =>true)
    end
    def self.list_deleted
      all(:is_deleted => true)
    end
    def self.current
      all(:rank => 1, :is_deleted => false, :is_implemented => false)
    end
  end
  DataMapper.auto_upgrade!
end

get '/' do
  erb :index
end

post '/' do
  #            <td><form name=\"delete_pending_project\"><input type=\"submit\" value=\"Delete\"/></form></td>
  p = params['post']
  Project.new(:rank=>Project.count_pending+1, :name=>p['project_name'],:desc=>p['desc'],:long_desc=>p['long_desc'],:probs_techs=>p['probs_techs'],:submitter=>p['submitter']).save
  redirect '/'
end