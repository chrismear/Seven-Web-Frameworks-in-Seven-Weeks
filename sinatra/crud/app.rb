require "sinatra"
require "data_mapper"
require_relative "bookmark"

DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/bookmarks.db")
DataMapper.finalize.auto_upgrade!
