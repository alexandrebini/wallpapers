class window.Scroller
  constructor: ->
    @firstPage = @currentPage()
    @lastPage = @firstPage
    @paginationLocked = false
    @totalPages = $('#wallpapers').data('total_pages')
    $(window).scroll => @scroll()

  scroll: ->
    @lastScrollTop ?= 0
    tweak = 100
    scrollTop = $(window).scrollTop()
    if scrollTop > @lastScrollTop  # down scroll
      if scrollTop >= $(document).height() - $(window).height() - tweak
        @loadMore('down')
    else # up scroll
      if $(window).scrollTop() == 0
        @loadMore('up')
    @lastScrollTop = scrollTop

  loadMore: (direction) ->
    return if @paginationLocked

    switch direction
      when 'down'
        if @lastPage < @totalPages
          @lastPage += 1
          @setPage(@lastPage)
          @getData(@lastPage, 'down')
      when 'up'
        if @firstPage > 1
          @firstPage -= 1
          @setPage(@firstPage)
          @getData(@firstPage, 'up')

  getData: (page, direction) ->
    return if $("#wallpapers pg-#{ page }").length != 0

    container = $("<div class='page loading' data-page=#{ page }><span>page #{ page }</span></div>")
    if direction == 'down'
      container.appendTo $('#wallpapers')
    else
      container.prependTo $('#wallpapers')

    $('#wallpapers').masonry('appended', container)
    @paginationLocked = true

    $.ajax
      url: "/pg-#{ page }"
      dataType: 'json'
      success: (response) =>
        container.removeClass('loading')
        container.addClass('loaded')

        body = $(response.body)
        body.insertAfter(container)
        $('#wallpapers').masonry('appended', body)
        @paginationLocked = false

      error: (e) =>
        console.log e

  setPage: (page) ->
    switch
      when page == 1
        path = window.location.pathname.replace(/pg-(\d+)/, '')
      when window.location.pathname.match(/pg-(\d+)/)
        path = window.location.pathname.replace(/pg-(\d+)/, "pg-#{ page }")
      else
        path = "#{ window.location.pathname }pg-#{ page }"

    return false if path == window.location.pathname

    if typeof(window.history.pushState) == 'function'
      window.history.pushState(null, null, path)
    else
      location.hash = path

    return true

  currentPage: ->
    matcher = location.href.match(/pg-(\d+)/)
    if matcher?
      return parseInt(matcher[1])
    else
      1