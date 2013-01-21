App.ApplicationController = Ember.Controller.extend
  isHome: (->
    @get('currentRoute') == 'home'
  ).property('currentRoute')

  isWallpapers: (->
    @get('currentRoute') == 'wallpapers'
  ).property('currentRoute')