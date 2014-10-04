jQuery = require 'jquery'

app = require './views/app.coffee'

jQuery ->
    app.start()