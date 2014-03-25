noflo = require 'noflo'
gsap = require 'gsap'

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
      repeat: new noflo.Port 'number'
      reverse: new noflo.Port 'boolean'
      easing: new noflo.Port 'string'
    @outPorts =
      started: new noflo.Port 'bang'
      stopped: new noflo.Port 'bang'
      value: new noflo.Port 'bang'

    @inPorts.from.on 'data', (value) =>
      @getTween().vars.startAt = { x: value }

    @inPorts.to.on 'data', (value) =>
      @getTween().updateTo({ x: value })

    @inPorts.duration.on 'data', (value) =>
      @getTween().duration(value)

    @inPorts.start.on 'data', (value) =>
      @getTween().play()
      @getTween().paused(false)

    @inPorts.stop.on 'data', (value) =>
      @getTween().paused(true)
      @getTween().seek(0)

    @inPorts.pause.on 'data', (value) =>
      @getTween().paused(true)

    @inPorts.unpause.on 'data', (value) =>
      @getTween().paused(false)

  getTween: () ->
    return @tween if @tween
    @obj =
      x: 0
    @tween = new gsap.TweenMax(@obj, 1000, { x:1 })

  shutdown: () ->
    return unless @tween
    @tween.kill()
    delete @tween

exports.getComponent = -> new Tween
