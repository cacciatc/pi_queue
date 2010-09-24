require File.dirname(__FILE__) + '/spec_helper'

describe "pi-queue page" do
  include Rack::Test::Methods
  def app
    @app ||= Sinatra::Application
  end
  
  it "should have a list of implemented projects" do
    get '/'
    Hpricot(last_response.body).search("table[@name='implemented_projects']").should_not == [].empty?
  end
  
  it "should have a list of deleted projects" do
    get '/'
    Hpricot(last_response.body).search("table[@name='deleted_projects']").should_not == [].empty?
  end
  
  it "should have a list of pending projects" do
    get '/'
    Hpricot(last_response.body).search("table[@name='pending_projects']").should_not == [].empty?
  end
  
  it "should have a current project" do
    get '/'
    Hpricot(last_response.body).search("table[@name='current_project']").should_not == [].empty?
  end
  
  it "should allow a user to add a new project" do
    get '/'
    Hpricot(last_response.body).search("form[@name='create_new_project']").should_not == [].empty?
  end
  
  it "should allow a user to delete an existing pending project" do
    get '/'
    Hpricot(last_response.body).search("form[@name=\"delete_pending_project\"]").should_not == [].empty?
  end
  
  it "should allow a user to move a pending project up in rank" do
    pending
  end
  
  it "should allow a user to undelete a deleted project" do
    get '/'
    Hpricot(last_response.body).search("form[@name=\"restore_pending_project\"]").should_not == [].empty?
  end
  
  it "should use basic HTTP authentication" do
    get '/protected'
    last_response.status.should == 401
  end
end