require 'open-uri'

Source.create(name: 'HD Wallpapers', url: 'http://www.hdwallpapers.in') # id 1
Source.create(name: 'InterfaceLIFT', url: 'http://interfacelift.com')   # id 2
Source.create(name: 'GoodFon', url: 'http://www.goodfon.com')           # id 3

YAML.load_file("#{ Rails.root }/db/seeds.yml").each do |attrs|
  image = open(attrs[:image_url])

  Wallpaper.create(
    title: attrs[:title],
    source_id: attrs[:source_id],
    source_url: attrs[:source_url],
    image_src: attrs[:image_src],
    tags: attrs[:tags].map do |name|
      Tag.find_or_create_by_name(name)
    end,
    image: image,
    image_file_name: File.basename(attrs[:image_src]),
    views: (rand * 9999).to_i
  )

  image.close
end