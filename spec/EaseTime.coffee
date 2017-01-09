noflo = require 'noflo'

unless noflo.isBrowser()
  chai = require 'chai'
  path = require 'path'
  baseDir = path.resolve __dirname, '../'
else
  baseDir = 'noflo-tween'

describe 'EaseTime component', ->
  c = null
  start = null
  duration = null
  tick = null
  reverse = null
  stop = null
  started = null
  value = null
  stopped = null
  loader = null
  before ->
    loader = new noflo.ComponentLoader baseDir
  beforeEach (done) ->
    @timeout 4000
    loader.load 'tween/EaseTime', (err, instance) ->
      return done err if err
      c = instance
      start = noflo.internalSocket.createSocket()
      duration = noflo.internalSocket.createSocket()
      tick = noflo.internalSocket.createSocket()
      reverse = noflo.internalSocket.createSocket()
      stop = noflo.internalSocket.createSocket()
      c.inPorts.start.attach start
      c.inPorts.duration.attach duration
      c.inPorts.tick.attach tick
      c.inPorts.reverse.attach reverse
      c.inPorts.stop.attach stop
      started = noflo.internalSocket.createSocket()
      c.outPorts.started.attach started
      value = noflo.internalSocket.createSocket()
      c.outPorts.value.attach value
      stopped = noflo.internalSocket.createSocket()
      c.outPorts.stopped.attach stopped
      done()
  afterEach ->
    c.outPorts.started.detach started
    c.outPorts.value.detach value
    c.outPorts.stopped.detach stopped

  describe 'start a timeline', ->
    it 'should get started output and value = 0', (done) ->
      expected = [
        ['started', true]
        ['value', 0.0]
      ]
      started.on 'data', (data) ->
        exp = expected.shift()
        chai.expect(exp[0]).to.equal 'started'
        chai.expect(data).to.equal exp[1]
        return done() unless expected.length
      value.on 'data', (data) ->
        exp = expected.shift()
        chai.expect(exp[0]).to.equal 'value'
        chai.expect(data).to.be.least exp[1]
        chai.expect(data).to.be.most 0.01
        return done() unless expected.length

      duration.send 1000
      start.send true
      tick.send true
