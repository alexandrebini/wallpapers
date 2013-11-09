require 'nokogiri'
require 'open-uri'
require 'net/http'
require 'csv'

module Crawler
  require File.expand_path '../file_helper', __FILE__
  require File.expand_path '../url_opener', __FILE__
  require File.expand_path '../base', __FILE__

  Dir[File.expand_path '../sources/*.rb'].each do |source|
    require source
  end
end