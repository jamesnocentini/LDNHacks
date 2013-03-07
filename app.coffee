express = require 'express'
app = express()
RedisStore = require('connect-redis')(express)
url = require('url')

# Assets path
app.use require('connect-assets')()
app.set 'view engine', 'jade'

# Parse POST data
app.use express.bodyParser()
# Parse Cookie Data
app.use express.cookieParser('many')


# Launch Main App
PORT = process.env.PORT || 5000
app.listen PORT, ->
  console.log "ready to hack - listening on port #{PORT}"

# Redis
redis = require('redis')
options = { parser: 'javascript'}
redisClient = redis.createClient(10382, 'dory.redistogo.com', options)
redisClient.auth('22be40d5a50b2875d679bd3d3974b912')

app.use express.session {secret: "LDNHacks", store: new RedisStore({client: redisClient})}
callback_url = ''
app.configure('development', ->
  callback_url="http://localhost:5000/auth/twitter/callback"
)
app.configure('production', ->
  callback_url="http://londonhackathons.herokuapp.com/auth/twitter/callback"
)

app.use express.logger()
app.use app.router

app.get '/', (req, res) ->

  res.render 'index'


user = {screen_name: "Guest", profile_pic: "none"}
OAuth = require('oauth').OAuth
#New OAuth function to connect to Twitter API
oauth = new OAuth(
  "https://api.twitter.com/oauth/request_token",
  "https://api.twitter.com/oauth/access_token",
  "7QzOIjxJMGIZZbtM5Yxyig",
  "wxcxwj21rMFO2fH0vsfluGdbH4gw2TPwSArmHSA2vZQ",
  "1.1A",
  callback_url,
  "HMAC-SHA1"
)
app.get '/auth/twitter', (req, res) ->
  oauth.getOAuthRequestToken (error, oauth_token, oauth_token_secret, results) ->

    if error
      console.log(error)
      res.send "Authentification failed"
    else
      req.session.oauth =
        token: oauth_token,
        token_secret: oauth_token_secret


      res.redirect 'https://twitter.com/oauth/authenticate?oauth_token='+oauth_token
#Callback
app.get '/auth/twitter/callback', (req, res, next) ->

  if req.session.oauth
    console.log "Yo"
    console.log(req.session)
    req.session.oauth.verifier = req.query.oauth_verifier
    oauth_data = req.session.oauth

    oauth.getOAuthAccessToken(
      oauth_data.token,
      oauth_data.token_secret,
      oauth_data.verifier,
      (error, oauth_access_token, oauth_access_token_secret, results) ->
        if error
          console.log error
          res.send "Authentification Failue!"

        else
          req.session.oauth.access_token = oauth_access_token
          req.session.oauth.access_token_secret = oauth_access_token_secret
          req.session.username = results.screen_name

          redisClient.get('user:username:'+results.screen_name+':id', (err, reply) ->
            #Save in DB
            if !reply
              #User doesn't exist, save it to DB
              redisClient.incr('user_id')
              redisClient.get('user_id', (err, reply) ->
                if err || !reply
                  console.log(err, reply)
                  return
              )

              id = parseInt(reply)
              redisClient.sadd('user:id', id)
              redisClient.hset('user:'+id, 'username', results.screen_name)
              redisClient.hset('user:'+id, 'service_user_id', results.user_id)

              redisClient.set('user:username:'+results.screen_name+':id', id)





          )

          res.redirect('/');
    )


  else
    res.redirect '/'

#Send the user infos (Guest if not logged in via OAuth)
app.get '/auth/twitter/user', (req, res) ->
  # Get request to Twitter API to get the user infos
  oauth.get('https://api.twitter.com/1.1/users/show.json?screen_name='+req.session.username, req.session.oauth.access_token, req.session.oauth.access_token_secret, (error, data, response) ->
    data = JSON.parse data
    user = { screen_name: data.screen_name, profile_pic: data.profile_image_url}
  )
  res.send user
  console.log(req.session)


#Parse the body of the post request and store it in a Redis List
app.post '/participate', (req, res) ->
  data = req.body
  hackathonList = data.hackathon

  #Redis Lists store strings
  data = JSON.stringify({hackathon: data.hackathon, screen_name: data.screen_name, profile_pic: data.profile_pic})
  console.log(data)
  redisClient.lpush(hackathonList, data, (err, response)  ->
      redisClient.ltrim(hackathonList, 0, 15)
      if response
        console.log("success")
  )


# Parse the strings fetched from redis to JSON
participantsJSON = []
parseFunction = (participants) ->
  participantsJSON = []
  participants.forEach((participant) ->
    participant = JSON.parse(participant)
    participantsJSON.push(participant)

  )

#Send the list of participants to each hackathon participants directive
app.get '/participants/hack1', (req, res) ->
  redisClient.lrange("hack1", 0 , -1, (error, participants) ->
    parseFunction(participants)
    res.send participantsJSON
  )

app.get '/participants/hack2', (req, res) ->
  redisClient.lrange("hack2", 0 , -1, (error, participants) ->
    parseFunction(participants)
    res.send participantsJSON
  )

app.get '/participants/hack3', (req, res) ->
  redisClient.lrange("hack3", 0, -1, (error, participants) ->
    parseFunction(participants)
    res.send participantsJSON
  )

app.get '/participants/hack4', (req, res) ->
  redisClient.lrange("hack4", 0 , -1, (error, participants) ->
    parseFunction(participants)
    res.send participantsJSON
  )

app.get '/participants/hack5', (req, res) ->
  redisClient.lrange("hack5", 0 ,-1, (error, participants) ->
    parseFunction(participants)
    res.send participantsJSON
  )


console.log(app.settings.env)