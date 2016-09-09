should = require('should')
assert = require('assert')

describe 'Configuration', () ->

    it 'configures the application correctly.', (done) ->
        [config, sslOptions] = require '../config'
        config.env.should.be.equal('local')
        done()

