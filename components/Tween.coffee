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
      autoreverse: new noflo.Port 'boolean'
      easing: new noflo.Port 'string'
    @outPorts =
      started: new noflo.Port 'bang'
      stopped: new noflo.Port 'bang'
      value: new noflo.Port 'bang'

    # params
    @inPorts.from.on 'data', (value) =>
      @getTween().vars.startAt = { x: value }
    @inPorts.to.on 'data', (value) =>
      @getTween().updateTo({ x: value })
    @inPorts.duration.on 'data', (value) =>
      @getTween().duration(parseFloat(value) / 1000.0)
    @inPorts.repeat.on 'data', (value) =>
      @getTween().repeat(value)
    @inPorts.autoreverse.on 'data', (value) =>
      @getTween().yoyo(value)

    # actions
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
    params =
      x: 1
      ease: 'linear'
      onStart: () =>
        return unless @outPorts.started.isAttached()
        @outPorts.started.send(true)
        @outPorts.started.disconnect()
      onUpdate: () =>
        return unless @outPorts.value.isAttached()
        @outPorts.value.send(@obj.x)
        @outPorts.value.disconnect()
      onComplete: () =>
        return unless @outPorts.stopped.isAttached()
        @outPorts.stopped.send(true)
        @outPorts.stopped.disconnect()
    @tween = new gsap.TweenMax(@obj, 1, )

  shutdown: () ->
    return unless @tween
    @tween.kill()
    delete @tween

exports.getComponent = -> new Tween
