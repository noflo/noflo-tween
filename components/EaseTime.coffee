noflo = require 'noflo'

class EaseTime extends noflo.Component
  description: 'Converts time to normalized value between 0 and 1 for Ease'
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
      paused: new noflo.Port 'bang'
      unpaused: new noflo.Port 'bang'
      value: new noflo.Port 'bang'


    @running = false
    @duration = 500
    @repeat = @repeatCount = 0
    @reverse = false
    @autoreverse = false
    @direction = @startDirection = true

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
      @startDirection = !value
      @direction = @startDirection unless @autoreverse

    # tick
    @inPorts.tick.on 'data', () =>
      @advanceTimeline()


  start: () ->
    return if @running
    @lastTime = @currentTime()
    @elapsedTime = 0
    @repeat = @repeatCount
    @direction = @startDirection
    @running = true
    return unless @outPorts.started.isAttached()
    @outPorts.started.send(true)
    @outPorts.started.disconnect()

  stop: () ->
    return unless @running
    @running = false
    return unless @outPorts.stopped.isAttached()
    @outPorts.stopped.send(true)
    @outPorts.stopped.disconnect()

  pause: () ->
    return unless @running
    @running = false
    return unless @outPorts.paused.isAttached()
    @outPorts.paused.send(true)
    @outPorts.paused.disconnect()

  unpause: () ->
    return if @running
    @lastTime = @currentTime()
    @running = true
    return unless @outPorts.unpaused.isAttached()
    @outPorts.unpaused.send(true)
    @outPorts.unpaused.disconnect()

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

exports.getComponent = -> new EaseTime
