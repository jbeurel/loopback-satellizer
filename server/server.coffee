loopback = require('loopback')
boot = require('loopback-boot')
app = module.exports = loopback()
# Bootstrap the application, configure models, datasources and middleware.
# Sub-apps like REST API are mounted via boot scripts.
boot app, __dirname

app.start = ->
  # start the web server
  app.listen ->
    app.emit 'started'
    console.log 'Web server listening at: %s', app.get('url')
    return

# start the server if `$ node server.js`
if require.main == module
  app.start()
