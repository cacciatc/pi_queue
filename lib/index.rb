require 'rubygems'
require 'sinatra'
require 'datamapper'
#require 'dm-postgres-adapter'
#require 'do_sqlite3'

configure do
  class Project
    include DataMapper::Resource
    #DataMapper.setup(:default, ENV['DATABASE_URL'] || 'sqlite3://pi_projects.db')
    DataMapper.setup(:default, 'sqlite3::memory:')
    property :mid, Serial
    property :name, String,      :required=>true, :default=>''
    property :desc, String,      :required=>true, :default=>''
    property :long_desc, String, :required=>true, :default=>''
    property :submitter, String, :required=>true, :default=>''
    property :probs_techs,String, :required=>true, :default=>''
    property :url, String, :default=>''
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
        p.save
      end
    end
  end
  DataMapper.auto_upgrade!
end

use Rack::Auth::Basic do |username, password|
  [username, password] == ['roman', 'colonies25']
end

get '/' do
  erb :index
end

post '/update_rank' do
  params['data'].split('&').inject(rank = 2) do |rank,item|
    mid = item.split('=').last.to_i
    p = Project.get(mid)
    p.rank = rank
    p.is_deleted     = false
    p.is_implemented = false
    p.save
    rank += 1
  end
end

post '/update_implemented' do
  params['data'].split('&').each do |item|
    mid = item.split('=').last.to_i
    p = Project.get(mid)
    p.rank = -1
    p.is_deleted     = false
    p.is_implemented = true
    p.save
  end
end

post '/update_deleted' do
  params['data'].split('&').each do |item|
    mid = item.split('=').last.to_i
    p = Project.get(mid)
    p.rank = -1
    p.is_deleted     = true
    p.is_implemented = false
    p.save
  end
end

post '/update_current' do
  p = Project.all(:rank => 1).first
  p.is_implemented = true
  p.rank = -1
  p.save
  Project.shift_rank_once_after(1)
  redirect '/'
end

post '/' do
  p = params['post']
  Project.new(:rank=>Project.count_pending+1, :name=>p['project_name'],:desc=>p['desc'],:long_desc=>p['long_desc'],:probs_techs=>p['probs_techs'],:submitter=>p['submitter'],:url=>p['url']).save
  redirect '/'
end