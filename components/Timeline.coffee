noflo = require 'noflo'

class Timeline extends noflo.Component
  description: 'Timeline component'
  icon: 'cogs'
  constructor: ->
    @inPorts =
      tick: new noflo.Port 'bang'
      start: new noflo.Port 'bang'
      pause: new noflo.Port 'bang'
      unpause: new noflo.Port 'bang'
      stop: new noflo.Port 'bang'
      duration: new noflo.Port 'number'
      repeat: new noflo.Port 'number'
      reverse: new noflo.Port 'boolean'
      autoreverse: new noflo.Port 'boolean'
    @outPorts =
      started: new noflo.Port 'bang'
      stopped: new noflo.Port 'bang'
      value: new noflo.Port 'bang'


    @running = false
    @duration = 500
    @repeat = @repeatCount = 0
    @reverse = false
    @autoreverse = false
    @direction = true

    # control
    @inPorts.start.on 'data', () =>
      @start()
    @inPorts.stop.on 'data', () =>
      @stop()
    @inPorts.pause.on 'data', () =>
      @pause()
    @inPorts.unpause.on 'data', () =>
      @unpause()

    # parameters
    @inPorts.duration.on 'data', (value) =>
      @duration = value
    @inPorts.repeat.on 'data', (value) =>
      @repeatCount = value
    @inPorts.autoreverse.on 'data', (value) =>
      @autoreverse = value
    @inPorts.reverse.on 'data', (value) =>
      @direction = !value

    # tick
    @inPorts.tick.on 'data', () =>
      @advanceTimeline()


  start: () ->
    @lastTime = @currentTime()
    @elapsedTime = 0
    @repeat = @repeatCount
    @running = true
    return unless @outPorts.started.isAttached()
    @outPorts.started.send(true)
    @outPorts.started.disconnect()

  stop: () ->
    @elapsedTime = 0
    @running = false
    return unless @outPorts.stopped.isAttached()
    @outPorts.stopped.send(true)
    @outPorts.stopped.disconnect()

  pause: () ->
    @running = false

  unpause: () ->
    @lastTime = @currentTime()
    @running = true

  emitPosition: () ->
    return unless @outPorts.value.isAttached()
    pos = @elapsedTime / @duration
    pos = 1.0 - pos unless @direction
    @outPorts.value.send(pos)
    @outPorts.value.disconnect()

  currentTime: () ->
    date = new Date()
    return date.getTime()

  isComplete: () ->
    return false if @repeat > 0
    return false if @elapsedTime < @duration
    return true

  advanceTimeline: () ->
    return unless @running

    # Measure delta
    t = @currentTime()
    delta = t - @lastTime
    @lastTime = t

    # Add to elapsedTime
    @elapsedTime += delta

    # End case
    if @isComplete()
      # fix value on bounds
      @elapsedTime = @duration
      @emitPosition()
      @stop()
      return

    # Continue case
    if @elapsedTime < @duration
      @emitPosition()
      return

    # Loop case
    @elapsedTime = @elapsedTime - @duration
    @direction = !@direction if @autoreverse
    @repeat -= 1 if @repeat > 0

    @emitPosition()

exports.getComponent = -> new Timeline