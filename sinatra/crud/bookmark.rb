require "data_mapper"

class Bookmark
  include DataMapper::Resource
  
  property :id, Serial
  property :url, String
  property :title, String
  property :created_at, DateTime, :default => lambda { |_, _| DateTime.now }
end
