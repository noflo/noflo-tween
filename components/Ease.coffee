noflo = require 'noflo'
ease = null
try
  ease = require 'ease-component'
catch
  ease = require 'ease'

class Ease extends noflo.Component
  description: 'Easing function component that takes a normalized value between 0
   and 1 and outputs eased value between from and to inputs'
  icon: 'cogs'
  constructor: ->
    @inPorts =
      from: new noflo.Port 'number'
      to: new noflo.Port 'number'
      type: new noflo.Port 'string'
      in: new noflo.Port 'number'

    @outPorts =
      out: new noflo.Port 'number'

    @from = 0
    @to = 1
    @func = @getEasing('linear')

    @inPorts.from.on 'data', (value) =>
      @from = value
    @inPorts.to.on 'data', (value) =>
      @to = value
    @inPorts.type.on 'data', (value) =>
      func = @getEasing(value)
      @func = func if func
    @inPorts.in.on 'data', (value) =>
      return unless @outPorts.out.isAttached()
      val = @from + @func(value) * (@to - @from)
      @outPorts.out.send(val)
      @outPorts.out.disconnect()

  getEasing: (name) ->
    return ease[name]

exports.getComponent = -> new Ease
