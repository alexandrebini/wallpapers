module WallpapersHelper
  def is_highlight_wallpaper?(wallpaper, highlight)
    wallpaper == highlight
  end

  def wallpaper_class(wallpaper, highlight)
    if is_highlight_wallpaper?(wallpaper, highlight)
      'wallpaper highlight'
    else
      'wallpaper'
    end
  end
end