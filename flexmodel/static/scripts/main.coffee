jQuery = require 'jquery'
require './lib/csrf'

app = require './views/app.coffee'

$ = jQuery = require 'jquery'
Backbone = require('backbone')
Backbone.$ = jQuery
Marionette = require 'backbone.marionette'
moment = require 'moment'

NavView = require './views/nav.coffee'

FlexCollection = require './models/flex_collection.coffee'
FlexModel = require './models/flex.coffee'

fields = require './views/fields.coffee'
FormField = fields.FormField
FormDateField = fields.FormDateField

table = require './views/table.coffee'
FlexTableView = table.FlexTableView
NoModelSelectedView = table.NoModelSelectedView


FormView = require './views/form.coffee'


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

jQuery ->
    app.start()