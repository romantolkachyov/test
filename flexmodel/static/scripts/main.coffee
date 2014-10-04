jQuery = require 'jquery'
require './lib/csrf'

app = require './views/app.coffee'

jQuery ->
    app.start()