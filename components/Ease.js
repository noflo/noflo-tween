const noflo = require('noflo');
const ease = require('ease-component');

const getEasing = (name) => ease[name] || ((n) => n);

exports.getComponent = () => {
  const c = new noflo.Component();
  c.description = 'Easing function component that takes a normalized value between 0 and 1 and outputs eased value between from and to inputs';
  c.icon = 'cogs';
  c.inPorts.add('from', {
    datatype: 'number',
    control: true,
  });
  c.inPorts.add('to', {
    datatype: 'number',
    control: true,
  });
  c.inPorts.add('type', {
    datatype: 'string',
    values: [
      'linear',
      'in-quad',
      'out-quad',
      'in-out-quad',
      'in-cube',
      'out-cube',
      'in-out-cube',
      'in-quart',
      'out-quart',
      'in-out-quart',
      'in-quint',
      'out-quint',
      'in-out-quint',
      'in-sine',
      'out-sine',
      'in-out-sine',
      'in-expo',
      'out-expo',
      'in-out-expo',
      'in-circ',
      'out-circ',
      'in-out-circ',
      'in-back',
      'out-back',
      'in-out-back',
      'in-bounce',
      'out-bounce',
      'in-out-bounce',
    ],
    default: 'linear',
    control: true,
  });
  c.inPorts.add('in', {
    datatype: 'number',
  });
  c.outPorts.add('out', {
    datatype: 'number',
  });
  c.process((input, output) => {
    if (!input.hasData('from', 'to', 'in')) { return; }
    if (input.attached('type').length && !input.hasData('type')) { return; }
    const [from, to, value] = input.getData('from', 'to', 'in');
    let type = 'linear';
    if (input.hasData('type')) {
      type = input.getData('type');
    }
    const func = getEasing(type);
    const val = from + (func(value) * (to - from));
    output.sendDone({ out: val });
  });
  return c;
};
