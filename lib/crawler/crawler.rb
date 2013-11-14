require 'nokogiri'
require 'open-uri'
require 'net/http'
require 'csv'
require 'public_suffix'
require 'singleton'

module Crawler
  autoload :FileHelper,       File.expand_path('../base/file_helper', __FILE__)
  autoload :UrlOpener,        File.expand_path('../base/url_opener', __FILE__)
  autoload :Worker,           File.expand_path('../base/worker', __FILE__)
  autoload :ActMacro,         File.expand_path('../base/act_macro', __FILE__)
  autoload :ClassMethods,     File.expand_path('../base/class_methods', __FILE__)
  autoload :InstanceMethods,  File.expand_path('../base/instance_methods', __FILE__)

  autoload :Goodfon,          File.expand_path('../goodfon', __FILE__)
  autoload :Hdwallpapers,     File.expand_path('../hdwallpapers', __FILE__)
  autoload :Interfacelift,    File.expand_path('../interfacelift', __FILE__)
end