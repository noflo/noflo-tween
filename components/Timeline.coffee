noflo = require 'noflo'
ease = null
try
  ease = require 'ease-component'
catch
  ease = require 'ease'

class Timeline extends noflo.Component
  description: 'Timeline with multiple tracks and keyframes'
  icon: 'clock-o'
  constructor: ->
    @inPorts = new noflo.InPorts
      # Tracks array of objects with name, group, keyframes
      # keyframes array of objects with time, value, easing
      tracks:
        datatype: 'array'
        description: 'configuration array of tracks and keyframes'
      play:
        datatype: 'bang'
      pause:
        datatype: 'bang'
      stop:
        datatype: 'bang'
      length:
        datatype: 'number'
        description: 'length in ms of timeline'
        value: 3000
      loop:
        datatype: 'boolean'
      time:
        datatype: 'number'
        description: 'skip to time'
      percent:
        datatype: 'number'
        description: 'skip to percent, 0-1'
      speed:
        datatype: 'number'
        description: '1.0 = normal speed'
        default: 1
      fps:
        datatype: 'number'
        description: 'maximum fps of animation loop'
        default: 60

    @outPorts = new noflo.OutPorts
      out:
        datatype: 'number'
        addressable: true
      play:
        datatype: 'bang'
      pause:
        datatype: 'bang'
      stop:
        datatype: 'bang'
      end:
        datatype: 'bang'
        description: 'fired when end is reached (or loops)'
      time:
        datatype: 'number'

    playing = false
    now = null
    percent = null
    time = null
    lastTime = null
    fps = 60
    frame = 1000/fps
    raf = null

    animate = () ->
      raf = requestAnimationFrame animate
      now = Date.now()
      if now-lastTime >= frame
        for track in tracks
          ################################# TODO

        lastTime = now

    @inPorts.play.on 'data', () ->
      raf = requestAnimationFrame animate

    @inPorts.pause.on 'data', () ->
      cancelAnimationFrame raf
      playing = false

    @inPorts.stop.on 'data', () ->
      cancelAnimationFrame raf
      playing = false
      time = 0

  getEasing: (name) ->
    return ease[name]

exports.getComponent = -> new Timeline
