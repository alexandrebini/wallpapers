namespace :crawler do
  desc 'import wallpapers from hdwallpapers.in'
  task hdwallpapers: :environment do
    require "#{Rails.root}/lib/tasks/crawler/hdwallpapers.rb"
    Crawler::Hdwallpapers.start!
  end
end