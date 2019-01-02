function manipulateTimes(component, wantedSeconds) {
  const c = component;
  const start = new Date();
  start.setTime(start.getTime() - (wantedSeconds * 1000));
  const end = new Date();
  end.setTime(start.getTime() + (c.state.timelineDefinition.total_time * 1000));
  c.state.startTime = start;
  c.state.endTime = end;
}

describe('Timeline component', () => {
  let c;
  let timeline;
  let start;
  let tick;
  let commands;
  let started;
  let finished;
  let error;
  before((callback) => {
    const loader = new noflo.ComponentLoader(baseDir);
    loader.load('tween/Timeline', (err, instance) => {
      if (err) {
        callback(err);
        return;
      }
      c = instance;
      timeline = noflo.internalSocket.createSocket();
      c.inPorts.timeline.attach(timeline);
      start = noflo.internalSocket.createSocket();
      c.inPorts.start.attach(start);
      tick = noflo.internalSocket.createSocket();
      c.inPorts.tick.attach(tick);
      callback();
    });
  });
  beforeEach(() => {
    commands = [
      noflo.internalSocket.createSocket(),
      noflo.internalSocket.createSocket(),
    ];
    commands.forEach((command, idx) => {
      c.outPorts.command.attach(command, idx);
    });
    started = noflo.internalSocket.createSocket();
    c.outPorts.started.attach(started);
    finished = noflo.internalSocket.createSocket();
    c.outPorts.finished.attach(finished);
    error = noflo.internalSocket.createSocket();
    c.outPorts.error.attach(error);
  });
  afterEach(() => {
    commands.forEach((command, idx) => {
      c.outPorts.command.detach(command, idx);
    });
    c.outPorts.started.detach(started);
    c.outPorts.finished.detach(finished);
    c.outPorts.error.detach(error);
  });

  describe('with a simple single-track animation', () => {
    it('should be able to set the definition', () => {
      timeline.send({
        total_time: 3,
        tracks: [
          {
            name: 'foo',
            commands: {
              0: ['start'],
              1: ['one'],
              3: ['three __ELAPSED__'],
            },
          },
        ],
      });
      chai.expect(c.state.timelineDefinition).to.be.an('object');
    });
    it('should send a started packet when started', (callback) => {
      error.once('data', callback);
      started.on('data', () => {
        callback();
      });
      start.send(true);
    });
    it('should send commands on first tick', (callback) => {
      error.once('data', callback);
      const receivedCommands = [];
      commands.forEach((command, idx) => {
        receivedCommands[idx] = [];
        command.on('data', (data) => {
          receivedCommands[idx].push(data);
          chai.expect(receivedCommands[0]).to.eql(['start']);
          callback();
        });
      });
      tick.send(true);
    });
    it('should send command on one-second tick', (callback) => {
      error.once('data', callback);
      const receivedCommands = [];
      commands.forEach((command, idx) => {
        receivedCommands[idx] = [];
        command.on('data', (data) => {
          receivedCommands[idx].push(data);
          chai.expect(receivedCommands[0]).to.eql(['one']);
          callback();
        });
      });
      manipulateTimes(c, 1.5);
      tick.send(true);
    });
    it('should send command and finish at three-second tick', (callback) => {
      error.once('data', callback);
      const receivedCommands = [];
      commands.forEach((command, idx) => {
        receivedCommands[idx] = [];
        command.on('data', (data) => {
          receivedCommands[idx].push(data);
        });
      });
      finished.once('data', () => {
        chai.expect(receivedCommands[0]).to.eql(['three 3']);
        callback();
      });
      manipulateTimes(c, 3);
      tick.send(true);
    });
  });
});
