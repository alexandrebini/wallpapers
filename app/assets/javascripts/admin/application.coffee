#= require jquery
#= require jquery_ujs
#= require handlebars
#= require ember
#= require ember-data

#= require_self
#= require ./store
#= require ./routes
#= require_tree ./models
#= require_tree ./controllers
#= require_tree ./helpers
#= require_tree ./views
#= require_tree ../templates

window.App = Ember.Application.create()