$ = jQuery = require 'jquery'
Backbone = require('backbone')
Backbone.$ = jQuery
Marionette = require 'backbone.marionette'

class FlexApplication extends Marionette.Application
    regions:
        nav: '#model_nav'
        table: '#table_view'
        form: '#form_view'

app = new FlexApplication

module.exports = app