noflo = require 'noflo'
trident = require 'trident-js'

class Tween extends noflo.Component
  description: 'Tweener component'
  icon: 'cogs'
  constructor: ->
    @inPorts =
      start: new noflo.Port 'bang'
      pause: new noflo.Port 'bang'
      unpause: new noflo.Port 'bang'
      stop: new noflo.Port 'bang'
      from: new noflo.Port 'number'
      to: new noflo.Port 'number'
      duration: new noflo.Port 'number'
      repeat: new noflo.Port 'number'
      autoreverse: new noflo.Port 'boolean'
      easing: new noflo.Port 'string'
    @outPorts =
      started: new noflo.Port 'bang'
      stopped: new noflo.Port 'bang'
      value: new noflo.Port 'bang'

    # params
    @inPorts.from.on 'data', (value) =>
      @getTween()
      @startValue = parseFloat(value)
    @inPorts.to.on 'data', (value) =>
      @getTween()
      @stopValue = parseFloat(value)
    @inPorts.duration.on 'data', (value) =>
      @getTween().duration = parseFloat(value)
    @inPorts.repeat.on 'data', (value) =>
      @getTween().repeatCount = parseInt(value)
    @inPorts.autoreverse.on 'data', (value) =>
      @getTween().repeatBehavior = if value then trident.TimelineRepeatBehavior.REVERSE else trident.TimelineRepeatBehavior.NORMAL
    @inPorts.easing.on 'data', (value) =>
      ease = @getEasing(value)
      return unless ease
      @easing = ease

    # actions
    @inPorts.start.on 'data', (value) =>
      @getTween().play()
    @inPorts.stop.on 'data', (value) =>
      @getTween().cancel()
    @inPorts.pause.on 'data', (value) =>
      @getTween().suspend()
    @inPorts.unpause.on 'data', (value) =>
      @getTween().resume()

  getEasing: (name) ->
    lowName = name.toLowerCase()
    s = lowName
    s = s.replace(/bounce/, "Bounce")
    s = s.replace(/linear/, "Linear")
    s = s.replace(/qua/, "Qua")
    s = s.replace(/cubic/, "Cubic")
    s = s.replace(/sin/, "Sin")
    s = s.replace(/circ/, "Circ")
    s = s.replace(/back/, "Back")
    s = s.replace(/elastic/, "Elastic")
    s = s.replace(/in$/, "In")
    s = s.replace(/out$/, "Out")
    s = s.replace(/inout$/, "InOut")

    console.log(name + ' -> ' + s)

    return null unless trident.EasingFunctions[s]
    return new trident.EasingFunctions[s]()

  getTween: () ->
    return @tween if @tween
    @startValue = 0.0
    @stopValue = 1.0
    @tween = new trident.Timeline()
    @easing = @getEasing('linear')
    @tween.addEventListener('onpulse', (timeline, durationFraction, timelinePosition) =>
      return unless @outPorts.value.isAttached()
      console.log('pulse durationF=' + durationFraction)
      console.log('pulse timelineP=' + timelinePosition)
      console.log('pulse start=' + @startValue)
      console.log('pulse stop=' + @stopValue)
      value = @startValue + @easing.map(durationFraction) * (@stopValue - @startValue)
      console.log('pulse value=' + value)
      @outPorts.value.send(value)
      @outPorts.value.disconnect())
    @tween.addEventListener('onstatechange', (timeline, oldState, newState, durationFraction, timelinePosition) =>
      if newState == trident.TimelineState.PLAYING_FORWARD or newState == trident.TimelineState.PLAYING_REVERSE
        if @outPorts.started.isAttached()
          @outPorts.started.send(true)
          @outPorts.started.disconnect()
      if newState == trident.TimelineState.DONE or newState == trident.TimelineState.CANCELLED
        if @outPorts.stopped.isAttached()
          @outPorts.stopped.send(true)
          @outPorts.stopped.disconnect())
    return @tween



  shutdown: () ->
    return unless @tween
    @tween.kill()
    delete @tween

exports.getComponent = -> new Tween
