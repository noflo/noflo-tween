noflo = require 'noflo'

unless noflo.isBrowser()
  chai = require 'chai'
  path = require 'path'
  baseDir = path.resolve __dirname, '../'
else
  baseDir = 'noflo-tween'

describe 'Ease component', ->
  c = null
  from = null
  to = null
  type = null
  ins = null
  out = null
  before (done) ->
    @timeout 4000
    loader = new noflo.ComponentLoader baseDir
    loader.load 'tween/Ease', (err, instance) ->
      return done err if err
      c = instance
      from = noflo.internalSocket.createSocket()
      to = noflo.internalSocket.createSocket()
      type = noflo.internalSocket.createSocket()
      ins = noflo.internalSocket.createSocket()
      c.inPorts.from.attach from
      c.inPorts.to.attach to
      c.inPorts.type.attach type
      c.inPorts.in.attach ins
      done()
  beforeEach ->
    out = noflo.internalSocket.createSocket()
    c.outPorts.out.attach out
  afterEach ->
    c.outPorts.out.detach out

  describe 'with default linear', ->
    it 'should get a linear response', (done) ->
      expected = [
        0
        500
        1000
      ]
      out.on 'data', (data) ->
        chai.expect(data).to.equal expected.shift()
        done() unless expected.length
      from.send 0
      to.send 1000
      ins.send 0
      ins.send 0.5
      ins.send 1.0
  describe 'with in-cube', ->
    it 'should get a in-cube response', (done) ->
      expected = [
        0
        0.5 * 0.5 * 0.5 * 1000
        1000
      ]
      out.on 'data', (data) ->
        chai.expect(data).to.equal expected.shift()
        done() unless expected.length
      type.send 'in-cube'
      from.send 0
      to.send 1000
      ins.send 0
      ins.send 0.5
      ins.send 1.0
