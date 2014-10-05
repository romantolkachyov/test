Backbone = require 'backbone'
Marionette = require 'backbone.marionette'

utils = require './utils.coffee'
get_field_list = utils.get_field_list

fields = require './fields.coffee'
FormField = fields.FormField
FormDateField = fields.FormDateField

class FormView extends Marionette.CompositeView
    template: require '../../templates/form.eco'
    events:
        'submit form': 'onFormSubmit'
    onFormSubmit: ->
        @children.each (view) =>
            field_name = view.model.get('name')
            @model.set field_name, view.get_value()
            view.model.set
                value: view.get_value()
                error: false
        @model.save {},
            success: =>
                @target_collection.add @model
                @create_empty_model()
                @render()
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
        @create_empty_model()

    create_empty_model: ->
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

module.exports = FormView