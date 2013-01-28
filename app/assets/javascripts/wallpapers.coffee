class window.Wallpapers
  constructor: ->
    new Scroller()

    $('#wallpapers').masonry
      itemSelector: '.wallpaper, .page'
      isAnimated: false
      isFitWidth: true
      columnWidth: 10