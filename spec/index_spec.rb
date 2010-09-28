require File.dirname(__FILE__) + '/spec_helper'

describe "pi-queue page" do
  include Rack::Test::Methods
  def app
    @app ||= Sinatra::Application
  end
  
  it "should have a list of implemented projects" do
    get '/'
    Hpricot(last_response.body).search("ul/@id='implemented_projects'").empty?.should_not == true
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
  
  it "should allow users to move rows from pending to deleted"
  it "should allow users to move rows from deleted to pending"
  it "should allow users to implement the current project"
  it "should have some css to make things pretty"
  it "should have a nice logo in a header picture"
end