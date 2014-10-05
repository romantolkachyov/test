Backbone = require 'backbone'
Marionette = require 'backbone.marionette'

utils = require './utils.coffee'
get_field_list = utils.get_field_list
setCaretToPos = utils.setCaretToPos

fields = require './fields.coffee'
FormField = fields.FormField

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
        if e.which == utils.ENTER_CODE
            @save_and_exit()
        else if e.which == utils.ESC_CODE
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

module.exports =
    FlexTableView: FlexTableView
    NoModelSelectedView: NoModelSelectedView