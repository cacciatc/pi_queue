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
    property :url, String
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
  
  Project.new(:rank=>Project.count_pending+1,:name=>'test1').save
  Project.new(:rank=>Project.count_pending+1,:name=>'test2').save
  Project.new(:rank=>Project.count_pending+1,:name=>'test3').save
  Project.new(:rank=>Project.count_pending+1,:name=>'test4',:is_deleted=>true).save
  Project.new(:rank=>Project.count_pending+1,:name=>'test5',:is_implemented=>true).save
  Project.new(:rank=>Project.count_pending+1,:name=>'test6').save
end

use Rack::Auth::Basic do |username, password|
  [username, password] == ['admin', 'admin']
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
    p.update
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
    p.update
  end
end

post '/update_deleted' do
  params['data'].split('&').each do |item|
    mid = item.split('=').last.to_i
    p = Project.get(mid)
    p.rank = -1
    p.is_deleted     = true
    p.is_implemented = false
    p.update
  end
end

post '/update_current' do
  p = Project.all(:rank => 1).first
  p.is_implemented = true
  p.rank = -1
  p.update
  Project.shift_rank_once_after(1)
  redirect '/'
end

post '/' do
  p = params['post']
  Project.new(:rank=>Project.count_pending+1, :name=>p['project_name'],:desc=>p['desc'],:long_desc=>p['long_desc'],:probs_techs=>p['probs_techs'],:submitter=>p['submitter'],:url=>p['url']).save
  redirect '/'
end