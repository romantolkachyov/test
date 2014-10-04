$ = jQuery = require 'jquery'
Backbone = require('backbone')
Backbone.$ = jQuery
Marionette = require 'backbone.marionette'


_model_defs = {}

get_field_list = (model) ->
    definition = window.db_schema[model]
    definition.fields


class FlexModel extends Backbone.Model


class FlexCollection extends Backbone.Collection
    model: FlexModel
    url: ->
        "/api/#{@model_id}"
    parse: (response) ->
        @row_total = response.count
        return response.results


class FlexModelView extends Marionette.ItemView
    tagName: 'tr'
    template: require('../../templates/row.eco')
    templateHelpers: ->
        get_field_list: @get_field_list
    get_field_list: => get_field_list(@model.collection.model_id)


class FlexTableView extends Marionette.CompositeView
    tagName: 'table'
    template: require('../../templates/table.eco')
    childView: FlexModelView
    childViewContainer: 'tbody'
    templateHelpers: ->
        get_column_list: @get_column_list

    get_column_list: =>
        field_list = []
        for field in get_field_list(@collection.model_id)
            field_list.push field.title
        field_list

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
        model_id: new_model_id
    collection = new TmpCollection
    app.table.show new FlexTableView
        collection: collection
    collection.fetch()

module.exports = app