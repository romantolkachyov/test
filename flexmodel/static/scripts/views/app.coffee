$ = jQuery = require 'jquery'
Backbone = require('backbone')
Backbone.$ = jQuery
Marionette = require 'backbone.marionette'
moment = require 'moment'

ENTER_CODE = 13
ESC_CODE = 27


_model_defs = {}

get_field_list = (model) ->
    definition = window.db_schema[model]
    definition.fields

setSelectionRange = (input, selectionStart, selectionEnd) =>
    if input.setSelectionRange
        input.focus()
        input.setSelectionRange selectionStart, selectionEnd
    else if input.createTextRange
        range = input.createTextRange()
        range.collapse true
        range.moveEnd 'character', selectionEnd
        range.moveStart 'character', selectionStart
        range.select()

setCaretToPos = (input, pos) ->
  setSelectionRange input, pos, pos


class FlexModel extends Backbone.Model


class FlexCollection extends Backbone.Collection
    model: FlexModel
    url: ->
        "/api/#{@model_id}"
    parse: (response) ->
        @row_total = response.count
        return response.results

class FormField extends Marionette.ItemView
    """ Form field representation
    """
    template: require('../../templates/form_field.eco')
    className: 'row'
    ui:
        input: 'input'
    modelEvents:
        'change:error': 'render'
    templateHelpers: ->
        'get_value': @get_value
        'error': @error

    get_value: =>
        @ui.input.val()

    error: =>
        @model.get 'error'

class FormDateField extends FormField
    onRender: ->
        picker = @ui.input.datepicker
            autoclose: true
            format: "yyyy-mm-dd"
            language: 'ru'

class FieldView extends FormField
    """ Table cell representation with inline edit behaivor

    TODO: Marionette.Behaivor
    """
    tagName: 'td'
    className: ''
    normal_template: require('../../templates/field.eco')
    edit_template: require('../../templates/field_edit.eco')
    events:
        'keydown input': 'input_keydown'
        'click': 'toggle_edit'
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
        if e.which == ENTER_CODE
            @save_and_exit()
        else if e.which == ESC_CODE
            @model.set 'edit', false
    save_and_exit: ->
        @model.set
            value: @ui.input.val()
            edit: false
            error: false
    get_value: =>
        @model.get 'value'
    onRender: ->
        if @model.get 'edit'
            setCaretToPos(@ui.input[0], @ui.input.val().length)

class DateFieldView extends FieldView
    toggle_edit: ->
        super()
        @ui.input.datepicker('show')
    # get_value: =>
    #     date = new Date super()
    #     console.log date
    onRender: ->
        if @model.get 'edit'
            picker = @ui.input.datepicker
                autoclose: true
                format: "yyyy-mm-dd"
                language: 'ru'
            picker.on 'changeDate', =>
                @save_and_exit()


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
                type: field.type
                edit: false
        @collection = new Backbone.Collection data
    templateHelpers: ->
        get_field_list: @get_field_list
    getChildView: (model) ->
        if model.get('type') == 'date'
            return DateFieldView
        else
            return FieldView
    get_field_list: => get_field_list(@model.collection.model_id)
    on_field_change: (model) ->
        field = model.get 'name'
        value = model.get 'value'
        @model.set field, value
        @model.save {},
            error: (error_model, data) ->
                resp = data.responseJSON
                model.set
                    edit: true
                    error: resp[field]


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


class FormView extends Marionette.CompositeView
    template: require '../../templates/form.eco'
    events:
        'submit form': 'onFormSubmit'
    onFormSubmit: ->
        @children.each (view) =>
            field_name = view.model.get('name')
            @model.set field_name, view.get_value()
        @model.save {},
            success: -> alert 'saved!'
            error: (model, data) =>
                for field, errors of data.responseJSON
                    field = @collection.where({name: field})[0]
                    field.set 'error', errors
        false
    childViewContainer: '.field_list'
    getChildView: (model) ->
        if model.get('type') == 'date'
            return FormDateField
        return FormField
    templateHelpers: ->
        get_field_list: @get_field_list

    initialize: (options) ->
        super options
        if not options.target_collection?
            throw 'no target for FormView'
        @target_collection = options.target_collection
        @model = new @target_collection.model
        @model.collection = @target_collection
        data = []
        for field in @get_field_list()
            data.push
                name: field.id
                value: @model.get field.id
                type: field.type
                title: field.title
        @collection = new Backbone.Collection data

    get_field_list: =>
        get_field_list @target_collection.model_id


class FlexApplication extends Marionette.Application
    regions:
        nav: '#model_nav'
        table: '#table_view'
        form: '#form_view'

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

    app.form.show new FormView
        target_collection: collection

module.exports = app