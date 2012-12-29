namespace :crawler do
  desc 'import wallpapers from hdwallpapers.in'
  task start: :environment do
    require "#{ Rails.root }/lib/tasks/crawler/hdwallpapers.rb"

    puts 'give your mysql root password'
    system "mysql -u root -p -e \"SET GLOBAL max_connections = 10000000;\""

    [
      Thread.new{ Crawler::Hdwallpapers.start! },
      Thread.new{ Crawler::Goodfon.start! }
    ].each(&:join)
  end
end