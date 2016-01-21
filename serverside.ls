require! {  
  async
  ribcage
  colors
      
  underscore: _
  helpers: h
  bluebird: p

  express
  ejs
  compression
  'cookie-parser'
}


env = {}

env.settings = settings = do
  production: false
  
  module:
      db:
          name: 'cal'
          host: 'localhost'
          port: 27017

      logger:
          outputs:
              Console: {}

      express4:
          port: 3001
          static: __dirname + '/static'
          views: __dirname + '/views'
          cookiesecret: 'QUoOiNLr6DeMRRM9jVVoriK7Wt12mw7EOGOxqMao+'
          log: false



initRibcage = -> new p (resolve,reject) ~>
  env.settings.module.express4.configure = (app) ->
    app.use cookieParser()
    app.set 'view engine', 'ejs'
    
    app.set 'views', env.settings.module.express4.views
    
    app.use express.static env.settings.module.express4.static, do
      setHeaders: (req) ->
        req.removeHeader 'Date'
        req.setHeader 'Cache-Control', 'public'
      index: false
      lastModified: false
      redirect: false
      etag: true
      dotfiles: 'ignore'
      #maxAge: helpers.day
      #expires: new Date().getTime() + (helpers.day * 10)

    app.use compression()

    app.set 'x-powered-by', false

    env.app.use (err, req, res, next) ~>
      if not env.settings.production
        res.status(500).send util.inspect(err)
        throw err

      env.log 'web request error', { error: util.inspect(err) }, 'error', 'http'
      console.error util.inspect(err)
      res.status(500).send 'error 500'

  ribcage.init env, (err,modules) ->
    if err then reject err else resolve true


initRoutes = -> new p (resolve,reject) ~> 
  env.app.get '/', (req,res) ->
    res.render 'index', { title: 'resbou cal', version: env.version, production: env.settings.production }

  
initModels = -> new p (resolve,reject) ~>
  MongoCollection = collections.MongoCollection.extend4000 do
    defaults:
      db: env.db

    env.entities = new liveMongo collection: 'entities'
    env.addresses = new liveMongo collection: 'addresses'
    env.transactions = new liveMongo collection: 'transactions'

    env.entity = env.entities.defineModel 'entity', do
      defaults:
        balance: 0


initRibcage().then -> initRoutes().then -> env.log 'initialized', {}, 'init', 'done'
