#Copyright (c) 2010 Chris Cacciatore
#
#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included in
#all copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#THE SOFTWARE.

require 'rubygems'
require 'sinatra'
require 'datamapper'
if ENV['DATABASE_URL']
  require 'dm-postgres-adapter'
else
  require 'dm-sqlite-adapter'
end

configure do
  
  class Project
    include DataMapper::Resource
    DataMapper.setup(:default, ENV['DATABASE_URL'] || 'sqlite://tmp.db')

    property :mid, Serial
    property :name, Text    
    property :desc, Text     
    property :long_desc, Text
    property :submitter, Text
    property :probs_techs, Text
    property :url, Text
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

get '/project/:mid' do |mid|
  @p = Project.get(mid.to_i)
  if @p != nil
    erb :project
  else
    'project does not exist'
  end
end

post '/project/:mid' do |mid|
  p = params['post']
  proj = Project.get(mid.to_i)
  proj.name = p['project_name']
  proj.desc = p['desc']
  proj.probs_techs = p['probs_techs']
  proj.url = p['url']
  proj.submitter = p['submitter']
  proj.long_desc = p['long_desc']
  proj.save
  redirect '/'
end

post '/update_rank' do
  projs = params['data'].split('&')
  rank = projs.size == 1 ? 1 : 2
  projs.inject(rank) do |rank,item|
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

get '/update_current' do
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