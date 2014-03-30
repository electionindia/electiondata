$("document").ready =>
  app = {}
  window.app = app

  app.StatesModel = Backbone.Model.extend
    initialize: =>
      #nothing

  app.StatesCollection = Backbone.Model.extend
    model: app.StatesModel
    url: "https://github.com/electionindia/electiondata/blob/master/json/constituency.json",
    parse: (resp, xhr) ->
      return resp.models

  app.HomeView = Backbone.View.extend
    el: "#main-view"
    template: "#template-main-view"
    render: ->
      h = _.template $(template)
      @$el.html h
      @

  app.router = Backbone.Router.extend
    routes:
      ""   : "default"
      ":state/:constituency" : "viewCandidates"

    initialize: ->
      return

    default: ->
      return

    viewCandidates: ->
      return