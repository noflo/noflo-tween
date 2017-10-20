noflo = require 'noflo'
ease = require 'ease-component'

getEasing = (name) ->
  return ease[name] or (n) -> return n

exports.getComponent = ->
  c = new noflo.Component
  c.description = 'Easing function component that takes a normalized value
   between 0 and 1 and outputs eased value between from and to inputs'
  c.icon = 'cogs'
  c.inPorts.add 'from',
    datatype: 'number'
    control: true
  c.inPorts.add 'to',
    datatype: 'number'
    control: true
  c.inPorts.add 'type',
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
    control: true
  c.inPorts.add 'in',
    datatype: 'number'
  c.outPorts.add 'out',
    datatype: 'number'
  c.process (input, output) ->
    return unless input.hasData 'from', 'to', 'in'
    return if input.attached('type').length and not input.hasData 'type'
    [from, to, value] = input.getData 'from', 'to', 'in'
    type = 'linear'
    if input.hasData 'type'
      type = input.getData 'type'
    func = getEasing type
    val = from + func(value) * (to - from)
    output.sendDone
      out: val
    return
