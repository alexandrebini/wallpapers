App.Source = DS.Model.extend
  name: DS.attr('string')
  url: DS.attr('string')
  wallpapers: DS.hasMany('App.Wallpaper')