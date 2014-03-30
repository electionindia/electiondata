// Generated by CoffeeScript 1.6.3
(function() {
  var _this = this;

  $("document").ready(function() {
    var app;
    app = {};
    window.app = app;
    app.StatesModel = Backbone.Model.extend({
      initialize: function() {}
    });
    app.StatesCollection = Backbone.Model.extend({
      model: app.StatesModel,
      url: "https://github.com/electionindia/electiondata/blob/master/json/constituency.json",
      parse: function(resp, xhr) {
        return resp.models;
      }
    });
    app.HomeView = Backbone.View.extend({
      el: "#main-view",
      template: "#template-main-view",
      render: function() {
        var h;
        h = _.template($(template));
        this.$el.html(h);
        return this;
      }
    });
    return app.router = Backbone.Router.extend({
      routes: {
        "": "default",
        ":state/:constituency": "viewCandidates"
      },
      initialize: function() {},
      "default": function() {},
      viewCandidates: function() {}
    });
  });

}).call(this);