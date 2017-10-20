noflo = require 'noflo'

getPosition = (ctx) ->
  pos = ctx.elapsedTime / ctx.duration
  pos = 1.0 - pos unless ctx.direction
  return pos

isComplete = (ctx) ->
  return false if ctx.repeat > 0
  return false if ctx.elapsedTime < ctx.duration
  return true

advanceTimeline = (ctx, callback) ->
  unless ctx.running
    return callback null

  # Measure delta
  t = Date.now()
  delta = t - ctx.lastTime
  ctx.lastTime = t

  # Add to elapsedTime
  ctx.elapsedTime += delta

  # End case
  if isComplete ctx
    # fix value on bounds
    ctx.running = false
    ctx.elapsedTime = ctx.duration
    callback null
    return

  # Continue case
  if ctx.elapsedTime < ctx.duration
    callback getPosition ctx
    return

  # Loop case
  ctx.elapsedTime = ctx.elapsedTime - ctx.duration
  ctx.direction = !ctx.direction if ctx.autoreverse
  ctx.repeat -= 1 if ctx.repeat > 0

  callback getPosition ctx

exports.getComponent = -> new EaseTime

exports.getComponent = ->
  c = new noflo.Component
  c.description = 'Converts time to normalized value between 0 and 1 for Ease'
  c.icon = 'cogs'
  c.inPorts.add 'tick',
    datatype: 'bang'
  c.inPorts.add 'start',
    datatype: 'bang'
  c.inPorts.add 'pause',
    datatype: 'bang'
  c.inPorts.add 'unpause',
    datatype: 'bang'
  c.inPorts.add 'stop',
    datatype: 'bang'
  c.inPorts.add 'duration',
    datatype: 'number'
    control: true
  c.inPorts.add 'repeat',
    datatype: 'number'
    control: true
  c.inPorts.add 'reverse',
    datatype: 'boolean'
    control: true
  c.inPorts.add 'autoreverse',
    datatype: 'boolean'
    control: true
  c.outPorts.add 'started',
    datatype: 'bang'
  c.outPorts.add 'stopped',
    datatype: 'bang'
  c.outPorts.add 'paused',
    datatype: 'bang'
  c.outPorts.add 'unpaused',
    datatype: 'bang'
  c.outPorts.add 'value',
    datatype: 'number'
  c.forwardBrackets = {}
  c.scopes = {}
  c.tearDown = (callback) ->
    c.scopes = {}
    do callback
  c.process (input, output) ->
    # Check that we have necessary options
    return if input.attached('duration').length and not input.hasData 'duration'
    return if input.attached('repeat').length and not input.hasData 'repeat'
    return if input.attached('reverse').length and not input.hasData 'reverse'
    return if input.attached('autoreverse').length and not input.hasData 'autoreverse'
    # Handle bangs
    if input.hasData 'start'
      input.getData 'start'
      duration = 500
      if input.hasData 'duration'
        duration = input.getData 'duration'
      repeat = 0
      if input.hasData 'repeat'
        repeat = input.getData 'repeat'
      reverse = false
      if input.hasData 'reverse'
        reverse = input.getData 'reverse'
      autoreverse = false
      if input.hasData 'autoreverse'
        autoreverse = input.getData 'autoreverse'
      c.scopes[input.scope] =
        running: true
        duration: duration
        repeat: repeat
        autoreverse: autoreverse
        lastTime: Date.now()
        elapsedTime: 0
        direction: !reverse
      output.send
        started: true
      return
    if input.hasData 'stop'
      input.getData 'stop'
      if c.scopes[input.scope]
        delete c.scopes[input.scope]
      output.sendDone
        stopped: true
      return
    if input.hasData 'pause'
      input.getData 'pause'
      unless c.scopes[input.scope]?.running
        output.done()
        return
      c.scopes[input.scope].running = false
      output.sendDone
        paused: true
      return
    if input.hasData 'unpause'
      input.getData 'unpause'
      unless c.scopes[input.scope]
        output.done()
        return
      if c.scopes[input.scope].running
        output.done()
        return
      c.scopes[input.scope].running = true
      output.sendDone
        unpaused: true
      return
    if input.hasData 'tick'
      input.getData 'tick'
      unless c.scopes[input.scope]?.running
        output.done()
        return
      advanceTimeline c.scopes[input.scope], (pos) ->
        if pos is null
          output.done()
          return
        output.sendDone
          value: pos
      return
