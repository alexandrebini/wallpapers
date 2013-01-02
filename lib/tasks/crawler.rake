namespace :crawler do
  desc 'import wallpapers from hdwallpapers.in'
  task start: :environment do
    [
      Thread.new{ Crawler::Goodfon.start! },
      Thread.new{ Crawler::Hdwallpapers.start! },
      Thread.new{ Crawler::Interfacelift.start! }
    ].each(&:join)
  end
end