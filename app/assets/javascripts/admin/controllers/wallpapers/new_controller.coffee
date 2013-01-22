App.WallpapersNewController = Ember.ObjectController.extend
  status: [
    Ember.Object.create({ name: 'Pending', id: 'pending' }),
    Ember.Object.create({ name: 'Reviewed', id: 'reviewed' })
  ]

  save: ->
    console.log 'save'
    @content.on 'didCreate', =>
      @transitionToRoute 'wallpapers.index', @content
    @store.commit()

  cancel: ->
    console.log 'index'
    @content.deleteRecord()
    @transitionToRoute('wallpapers.index')