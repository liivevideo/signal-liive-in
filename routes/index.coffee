express = require('express')
router = express.Router()

module.exports = (config) ->
  # GET home page. */
  configStr = JSON.stringify(config)
  router.get('/', (req, res, next) ->
    res.render('index', { title: 'Liive Video', config:configStr })
    return
  )
  return router

