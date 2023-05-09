require_relative "monkey_patches_pre"
require "sinatra"
require "data_mapper"
require "dm-serializer"
require "json"
require_relative "monkey_patches_post"
require_relative "bookmark"

class Hash
  def slice(*whitelist)
    whitelist.inject({}) {|result, key| result.merge(key => self[key])}
  end
end

DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/bookmarks.db")
DataMapper.finalize.auto_upgrade!

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end

def get_all_bookmarks
  Bookmark.all(:order => :title)
end

def get_all_bookmarks_ordered_by_created_at
  Bookmark.all(:order => :created_at)
end

get "/" do
  @bookmarks = get_all_bookmarks
  erb :bookmark_list
end

get "/bookmarks" do
  content_type :json
  get_all_bookmarks.to_json
end

get "/bookmarks_by_created_at" do
  content_type :json
  get_all_bookmarks_ordered_by_created_at.to_json
end

get "/bookmarks/:id" do
  id = params[:id]
  bookmark = Bookmark.get(id)
  content_type :json
  bookmark.to_json
end

post "/bookmarks" do
  input = params.slice "url", "title", "created_at"
  bookmark = Bookmark.create input
  # Created
  [201, "/bookmarks/#{bookmark['id']}"]
end

put "/bookmarks/:id" do
  id = params[:id]
  bookmark = Bookmark.get(id)
  input = params.slice "url", "title", "created_at"
  bookmark.update input
  204 # No Content
end

delete "/bookmarks/:id" do
  id = params[:id]
  bookmark = Bookmark.get(id)
  bookmark.destroy
  200 # OK
end
