
module.exports = (express, config) ->
  # GET home page. */
  router = express.Router()
  configStr = JSON.stringify(config)
  
  router.get('/', (req, res, next) ->
    console.log("request:" + JSON.stringify(req.headers))

    if (req.headers['x-forwarded-proto'] is 'https') or (req.secure and config.env is 'local')
      console.log("SSL REQUEST:")
      res.render('index', { title: config.title, source: config.cdn, config: configStr })
    else
      console.log("NON-SSL REQUEST")
      res.render('warning', { title: config.title, config: configStr })
    return
  )
  return router
