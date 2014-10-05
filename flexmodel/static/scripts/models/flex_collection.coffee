Backbone = require 'backbone'
FlexModel = require './flex.coffee'

class FlexCollection extends Backbone.Collection
    model: FlexModel
    url: ->
        "/api/#{@model_id}"

module.exports = FlexCollection