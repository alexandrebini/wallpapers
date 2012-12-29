namespace :crawler do
  desc 'import wallpapers from hdwallpapers.in'
  task start: :environment do
    require "#{ Rails.root }/lib/tasks/crawler/hdwallpapers.rb"

    [
      Thread.new{ Crawler::Hdwallpapers.start! },
      Thread.new{ Crawler::Goodfon.start! }
    ].each(&:join)
  end
end