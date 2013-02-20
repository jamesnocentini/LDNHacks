express = require 'express'
app = express()

PORT = process.env.PORT || 5000

app.set 'view engine', 'jade'

app.use express.logger()
app.use express.bodyParser()
app.use express.cookieParser()
app.use require('connect-assets')()
app.use app.router


app.get '/', (req, res) ->
  res.render 'index'

app.listen PORT, ->
  console.log "ready to hack - listening on port #{PORT}"

