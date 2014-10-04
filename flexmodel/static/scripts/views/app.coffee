$ = jQuery = require 'jquery'
Backbone = require('backbone')
Backbone.$ = jQuery
Marionette = require 'backbone.marionette'


ENTER_CODE = 13


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


class FieldView extends Marionette.ItemView
    tagName: 'td'
    normal_template: require('../../templates/field.eco')
    edit_template: require('../../templates/field_edit.eco')
    events:
        'keydown input': 'input_keydown'
        'click': 'toggle_edit'
    ui:
        input: 'input'
    modelEvents:
        'change:edit': 'render'
    getTemplate: ->
        if @model.get 'edit'
            return @edit_template
        else
            return @normal_template
    toggle_edit: ->
        if not @model.get 'edit'
            @model.set 'edit', true
    input_keydown: (e) ->
        if e.which == 13
            alert 'end edit'
            @model.set
                value: @ui.input.val()
                edit: false


class FlexModelView extends Marionette.CollectionView
    tagName: 'tr'
    childView: FieldView
    collectionEvents:
        'change:value': 'on_field_change'
    initialize: ->
        super()
        data = []
        for field in get_field_list(@model.collection.model_id)
            data.push
                name: field.id
                value: @model.get field.id
                type: @model.get 'type'
                edit: false
        @collection = new Backbone.Collection data
    templateHelpers: ->
        get_field_list: @get_field_list
    get_field_list: => get_field_list(@model.collection.model_id)
    on_field_change: (model) ->
        field = model.get 'name'
        value = model.get 'value'
        @model.set field, value
        @model.save()


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