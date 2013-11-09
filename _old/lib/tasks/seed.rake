namespace :seeds do
  task export: :environment do
    total = 100

    walls = []
    Wallpaper.downloaded.random.limit(total).each_with_index do |wall, index|
      puts "#{ index }/#{ total }"
      walls << export_wallpaper(wall)
    end

    file = File.open("#{ Rails.root }/db/seeds.yml", 'w+')
    file.write walls.to_yaml
    file.close
  end
end

def export_wallpaper(wall)
  attrs = {}
  attrs[:title] = wall.title
  attrs[:source_id] = wall.source_id
  attrs[:source_url] = wall.source_url
  attrs[:image_src] = wall.image_src
  attrs[:tags] = wall.tags.map{ |r| r.name }
  attrs[:image_url] = wall.image.url
  attrs
end
