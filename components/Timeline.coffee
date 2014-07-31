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
    @playing = false

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
        value: 1
      fps:
        datatype: 'number'
        description: 'maximum fps of animation loop'
        value: 60

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

  getEasing: (name) ->
    return ease[name]

exports.getComponent = -> new Timeline
