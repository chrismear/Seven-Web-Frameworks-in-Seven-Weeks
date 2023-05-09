require_relative "app"
require "rack/test"

describe "application" do
  include Rack::Test::Methods
  
  def app
    Sinatra::Application
  end

  it "creates a new bookmark" do
    header "accept", "application/json"

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
  
  it "updates a bookmark" do
    post "/bookmarks",
      {:url => "http://www.test.com", :title => "Test"}
    bookmark_uri = last_response.body
    id = bookmark_uri.split("/").last
    
    put "/bookmarks/#{id}", {:title => "Success"}
    last_response.status.should == 204
    
    get "/bookmarks/#{id}"
    retrieved_bookmark = JSON.parse(last_response.body)
    expect(retrieved_bookmark["title"]).to eq("Success")
  end
  
  it "deletes a bookmark" do
    post "/bookmarks",
      {:url => "http://www.test.com", :title => "Test"}
    bookmark_uri = last_response.body
    id = bookmark_uri.split("/").last
    
    delete "/bookmarks/#{id}"
    last_response.status.should == 200

    get "/bookmarks/#{id}"
    expect(last_response.body).to eq("null")
  end
  
  it "gets bookmarks in order of creation date" do
    # Destroy all existing bookmarks.
    Bookmark.destroy
    
    post "/bookmarks",
      {:url => "http://www.test.com", :title => "Latest", :created_at => Time.new(2023, 1, 1)}
    post "/bookmarks",
      {:url => "http://www.test.com", :title => "Earliest", :created_at => Time.new(2020, 1, 1)}

    
    get "/bookmarks_by_created_at"
    retrieved_bookmarks = JSON.parse(last_response.body)
    expect(retrieved_bookmarks.map{|b| b["title"]}).to eq(["Earliest", "Latest"])
    
  end
end
