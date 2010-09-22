require File.dirname(__FILE__) + '/spec_helper'

describe "pi-queue page" do
  include Rack::Test::Methods
  def setup
 
  end
  
  def app
    @app ||= Sinatra::Application
  end
  
  it "should have a list of implemented projects" do
    pending
  end
  
  it "should have a list of deleted projects" do
    pending
  end
  
  it "should have a list of pending projects" do
    pending
  end
  
  it "should have a current project" do
    pending
  end
  
  it "should allow a user to add a new project" do
    get '/'
    Hpricot(last_response.body).search("form[@name='create_new_project']").should_not == ""
  end
  
  it "should use basic HTTP authentication" do
    pending
  end
end