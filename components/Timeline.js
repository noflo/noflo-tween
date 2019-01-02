const noflo = require('noflo');
const debug = require('debug')('noflo-tween:timeline');

function replaceInCommand(command, state) {
  return command
    .replace('__START__', state.startTime.toISOString())
    .replace('__END__', state.endTime.toISOString())
    .replace('__ELAPSED__', parseInt(state.elapsed, 10));
}

exports.getComponent = () => {
  const c = new noflo.Component();
  c.icon = 'play';
  c.description = 'Execute a timeline';
  c.inPorts.add('timeline', {
    datatype: 'object',
    description: 'Timeline definition',
    required: true,
  });
  c.inPorts.add('start', {
    datatype: 'bang',
    description: 'Start executing the timeline',
  });
  c.inPorts.add('tick', {
    datatype: 'bang',
    description: 'Send track commands due this time',
  });
  c.outPorts.add('started', {
    datatype: 'bang',
  });
  c.outPorts.add('finished', {
    datatype: 'bang',
  });
  c.outPorts.add('command', {
    datatype: 'all',
    addressable: true,
  });
  c.outPorts.add('error', {
    datatype: 'object',
  });
  c.state = {};
  c.tearDown = (callback) => {
    c.state = {};
    callback();
  };
  c.process((input, output, context) => {
    if (input.hasData('timeline')) {
      c.state.timelineDefinition = input.getData('timeline');
      // TODO: Validate definition?
      if (!input.hasData('start')) {
        output.done();
        return;
      }
    }
    if (input.hasData('start') && c.state.timelineDefinition) {
      input.getData('start');
      if (c.state.running) {
        output.done(new Error('Timeline is already running'));
        return;
      }
      c.state.running = true;
      c.state.startTime = new Date();
      c.state.endTime = new Date();
      c.state.endTime.setTime(c.state.endTime.getTime()
        + (c.state.timelineDefinition.total_time * 1000));
      c.state.tracks = JSON.parse(JSON.stringify(c.state.timelineDefinition)).tracks;
      c.state.context = context;
      output.send({
        started: c.state.startTime,
      });
      return;
    }
    if (input.hasData('tick')) {
      input.getData('tick');
      if (!c.state.running) {
        output.done(new Error('Timeline is not running'));
        return;
      }
      const now = new Date();
      const elapsed = (now.getTime() - c.state.startTime.getTime()) / 1000;

      // Get commands to send at this time
      c.state.tracks.forEach((track, idx) => {
        const remainingCommands = {};
        Object.keys(track.commands).forEach((slot) => {
          const slotSeconds = parseInt(slot, 10);
          if (slotSeconds <= elapsed) {
            // Send this these commands
            track.commands[slot].forEach((command) => {
              let commandToSend = command;
              if (typeof command === 'string') {
                commandToSend = replaceInCommand(commandToSend, {
                  startTime: c.state.startTime,
                  endTime: c.state.endTime,
                  elapsed,
                });
              }
              debug(`At ${elapsed}s: send to ${idx}: '${commandToSend}'`);
              output.send({
                command: new noflo.IP('data', commandToSend, {
                  index: idx,
                }),
              });
            });
            return;
          }
          // Keep this for the future
          remainingCommands[slot] = track.commands[slot];
        });
        c.state.tracks[idx].commands = remainingCommands;
      });

      // Either finish or continue
      if (now >= c.state.endTime) {
        debug(`At ${elapsed}s: timeline finished`);
        c.state.context.deactivate();
        c.state = {
          timelineDefinition: c.state.timelineDefinition,
        };
        output.sendDone({
          finished: true,
        });
      } else {
        output.done();
      }
    }
  });
  return c;
};
