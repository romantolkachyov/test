Backbone = require 'backbone'
Marionette = require 'backbone.marionette'

class FormField extends Marionette.ItemView
    """ Form field representation
    """
    template: require '../../templates/form_field.eco'
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

module.exports =
    FormField: FormField
    FormDateField: FormDateField