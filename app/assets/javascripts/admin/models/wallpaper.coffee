App.Wallpaper = DS.Model.extend
  source: DS.belongsTo('App.Source')
  source_url: DS.attr('string')
  slug: DS.attr('string')
  # attachment
  image_src: DS.attr('string')
  status: DS.attr('string')