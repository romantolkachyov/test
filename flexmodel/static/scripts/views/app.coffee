$ = jQuery = require 'jquery'
Backbone = require('backbone')
Backbone.$ = jQuery
Marionette = require 'backbone.marionette'


class FlexModel extends Backbone.Model


class FlexCollection extends Backbone.Collection
    model: FlexModel


class FlexModelView extends Marionette.ItemView
    template: require('../../templates/row.eco')
    tagName: 'tr'


class FlexTableView extends Marionette.CompositeView
    template: require('../../templates/table.eco')
    childView: FlexModelView
    tagName: 'table'


class NoModelSelectedView extends Marionette.ItemView
    template: require('../../templates/empty_list.eco')


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


class FlexApplication extends Marionette.Application
    regions:
        nav: '#model_nav'
        table: '#table_view'

app = new FlexApplication

app.addInitializer (options) ->
    app.nav.show new NavView
    app.table.show new NoModelSelectedView

app.vent.on 'change_model', (new_model_id) ->
    class TmpCollection extends FlexCollection
        url: "/api/#{new_model_id}"
    collection = new TmpCollection
    app.table.show new FlexTableView
        collection: collection
    collection.fetch()

module.exports = app