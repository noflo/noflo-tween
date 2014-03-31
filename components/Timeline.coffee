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
    @position = 0.0
    @repeat = @repeatCount = 0
    @reverse = false
    @autoreverse = false

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

    # tick
    @inPorts.tick.on 'data', () =>
      @advanceTimeline()


  start: () ->
    @elapsedTime = 0
    @position = if @reverse then 1.0 else 0.0
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
    @running = true

  emitPosition: () ->
    return unless @outPorts.value.isAttached()
    @outPorts.value.send(@elapsedTime / @duration)
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
    if @lastTime
      delta = 0
    else
      t = @currentTime()
      diff = t - @lastTime
      @lastTime = t

    # Add to elapsedTime
    if @direction then @elapsedTime += diff else @elapsedTime -= diff

    # End case
    if @isComplete()
      @position = if @direction then 1.0 else 0.0
      @emitPosition()
      @stop()
      return

    # Continue case
    if @repeat < 1
      @emitPosition()
      return

    # Loop case
    if @autoreverse
      if @direction
        @elapsedTime = @elapsedTime - @duration
      else
        @elapsedTime = @duration - (@elapsedTime - @duration)
    else
      @elapsedTime = @elapsedTime - @duration

    @direction = !@direction if @autoreverse
    @repeat -= 1

    @emitPosition()

exports.getComponent = -> new Timeline
