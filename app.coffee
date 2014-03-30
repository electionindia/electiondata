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
      h = _.template $(@template).html()
      @$el.html h
      @

  app.CandidatesView = Backbone.View.extend
    el: "#main-view"
    template: "#template-candidates"
    render: ->
      h = _.template $(@template).html()
      @$el.html h
      @

  app.Router = Backbone.Router.extend
    routes:
      ""   : "default"
      ":state/:constituency" : "viewCandidates"

    initialize: ->
      return

    default: ->
      defview = new app.HomeView()
      defview.render()
      $(".headersearch").hide()
      return

    viewCandidates: ->
      canview = new app.CandidatesView()
      canview.render()
      $(".headersearch").show()
      return

  app.router = new app.Router()
  app.StatesCollection = new app.StatesCollection()
  Backbone.history.start({pushState: false, root: window.location.pathname})
