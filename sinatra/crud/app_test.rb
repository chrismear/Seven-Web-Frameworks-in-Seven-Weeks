require_relative "app"
require "rack/test"

describe "application" do
  include Rack::Test::Methods
  
  def app
    Sinatra::Application
  end

  it "creates a new bookmark" do
    get "/bookmarks"
    bookmarks = JSON.parse(last_response.body)
    last_size = bookmarks.size
    
    post "/bookmarks",
      {:url => "http://www.test.com", :title => "Test"}
      
    last_response.status.should == 201
    last_response.body.should match(/\/bookmarks\/\d+/)
    
    get "/bookmarks"
    bookmarks = JSON.parse(last_response.body)
    expect(bookmarks.size).to eq(last_size + 1)
  end
end
