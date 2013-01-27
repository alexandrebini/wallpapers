class window.Scroller
  constructor: ->
    @firstPage = @currentPage()
    @lastPage = @firstPage
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
    console.log direction
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

    container = $("<div class='page-#{ page } loading'></div>")
    if direction == 'down'
      container.appendTo $('#wallpapers')
    else
      container.prependTo $('#wallpapers')

    $.ajax
      url: "/pg-#{ page }"
      dataType: 'json'
      success: (response) =>
        container.append(response.body)
        container.removeClass('loading')
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