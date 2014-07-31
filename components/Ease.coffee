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
    @inPorts = new noflo.InPorts
      from:
        datatype: 'number'
      to:
        datatype: 'number'
      type:
        datatype: 'string'
        values: [
          'linear'
          'in-quad'
          'out-quad'
          'in-out-quad'
          'in-cube'
          'out-cube'
          'in-out-cube'
          'in-quart'
          'out-quart'
          'in-out-quart'
          'in-quint'
          'out-quint'
          'in-out-quint'
          'in-sine'
          'out-sine'
          'in-out-sine'
          'in-expo'
          'out-expo'
          'in-out-expo'
          'in-circ'
          'out-circ'
          'in-out-circ'
          'in-back'
          'out-back'
          'in-out-back'
          'in-bounce'
          'out-bounce'
          'in-out-bounce'
        ]
        default: 'linear'
      in:
        datatype: 'number'

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
    return ease[name] or (n) -> return n

exports.getComponent = -> new Ease
