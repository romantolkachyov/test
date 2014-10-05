Backbone = require 'backbone'
Marionette = require 'backbone.marionette'

app = require './app.coffee'

class NavItemView extends Marionette.ItemView
    tagName: 'li'
    template: require('../../templates/nav_item.eco')
    events:
        'click a': 'activate_menu'
    modelEvents:
        'change': 'render'

    activate_menu: ->
        for model in @model.collection.where({'active': true})
            model.set 'active', false
        @model.set 'active', true
        app.vent.trigger('change_model', @model.get('name'))

    onRender: ->
        if @model.get 'active'
            @$el.addClass 'active'
        else
            @$el.removeClass('active')


class NavView extends Marionette.CollectionView
    tagName: 'ul'
    className: 'side-nav'
    childView: NavItemView

    initialize: ->
        nav_data = []
        for model_name, definition of window.db_schema
            nav_data.push
                name: model_name
                title: definition.title
                active: false
        @collection = new Backbone.Collection nav_data
        super

module.exports = NavView