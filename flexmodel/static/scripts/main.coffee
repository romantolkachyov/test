require './lib/csrf'
$ = jQuery = require 'jquery'
Backbone = require('backbone')
Backbone.$ = jQuery
Marionette = require 'backbone.marionette'

app = require './views/app.coffee'

NavView = require './views/nav.coffee'
FlexCollection = require './models/flex_collection.coffee'
table = require './views/table.coffee'
FormView = require './views/form.coffee'


app.addInitializer (options) ->
    app.nav.show new NavView
    app.table.show new table.NoModelSelectedView

app.vent.on 'change_model', (new_model_id) ->
    class TmpCollection extends FlexCollection
        model_id: new_model_id
    collection = new TmpCollection
    app.table.show new table.FlexTableView
        collection: collection
    collection.fetch()

    app.form.show new FormView
        target_collection: collection

jQuery ->
    app.start()