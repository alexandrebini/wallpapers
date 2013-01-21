App.Router.reopen
  location: 'history'
  enableLogging: true

App.Router.map ->
  @resource 'admin', { path: '/admin' }, ->
    @route 'index'
    @route 'new'

  @resource 'wallpapers', { path: '/admin/wallpapers/' }, ->
    @route 'new'

App.AdminRoute = Ember.Route.extend
  setupController: (controller, model) ->
    @controllerFor('application').set('header', 'Home')
    @controllerFor('application').set('currentRoute', 'home')

App.WallpapersRoute = Ember.Route.extend
  setupController: (controller, model) ->
    @controllerFor('application').set('header', 'Wallpapers')
    @controllerFor('application').set('currentRoute', 'home')