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
      all(:is_deleted => false, :is_implemented =>false, :rank.gt => 1, :order => [ :rank.asc ])
    end
    def self.count_pending
      count(:is_deleted => false, :is_implemented =>false)
    end
    def self.list_implemented
      all(:is_deleted => false, :is_implemented =>true, :order => [ :created_at.desc ])
    end
    def self.list_deleted
      all(:is_deleted => true, :order => [ :created_at.desc ])
    end
    def self.current
      all(:rank => 1, :is_deleted => false, :is_implemented => false)
    end
    def self.shift_rank_once_after(rank)
      all(:rank.gt => rank).each do |p|
        p.rank -= 1
        p.update
      end
    end
  end
  DataMapper.auto_upgrade!
end

use Rack::Auth::Basic do |username, password|
  [username, password] == ['admin', 'admin']
end

get '/' do
  erb :index
end

post '/delete/:mid' do |mid|
  p = Project.get(mid.to_i)
  Project.shift_rank_once_after(p.rank)
  p.is_deleted = true
  p.rank = -1
  p.update
  redirect '/'
end

post '/restore/:mid' do |mid|
  p = Project.get(mid.to_i)
  p.is_deleted = false
  p.rank = Project.count_pending+1
  p.update
  redirect '/'
end

post '/' do
  p = params['post']
  Project.new(:rank=>Project.count_pending+1, :name=>p['project_name'],:desc=>p['desc'],:long_desc=>p['long_desc'],:probs_techs=>p['probs_techs'],:submitter=>p['submitter']).save
  redirect '/'
end