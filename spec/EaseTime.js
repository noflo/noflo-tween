describe('EaseTime component', () => {
  let c = null;
  let start = null;
  let duration = null;
  let tick = null;
  let stop = null;
  let started = null;
  let value = null;
  let stopped = null;
  let loader = null;
  before(() => {
    loader = new noflo.ComponentLoader(baseDir);
  });
  beforeEach(function (done) {
    this.timeout(4000);
    loader.load('tween/EaseTime', (err, instance) => {
      if (err) {
        done(err);
        return;
      }
      c = instance;
      start = noflo.internalSocket.createSocket();
      duration = noflo.internalSocket.createSocket();
      tick = noflo.internalSocket.createSocket();
      stop = noflo.internalSocket.createSocket();
      c.inPorts.start.attach(start);
      c.inPorts.duration.attach(duration);
      c.inPorts.tick.attach(tick);
      c.inPorts.stop.attach(stop);
      started = noflo.internalSocket.createSocket();
      c.outPorts.started.attach(started);
      value = noflo.internalSocket.createSocket();
      c.outPorts.value.attach(value);
      stopped = noflo.internalSocket.createSocket();
      c.outPorts.stopped.attach(stopped);
      done();
    });
  });
  afterEach(() => {
    c.outPorts.started.detach(started);
    c.outPorts.value.detach(value);
    c.outPorts.stopped.detach(stopped);
  });

  describe('start a timeline', () => it('should get started output and value = 0', (done) => {
    const expected = [
      ['started', true],
      ['value', 0.0],
    ];
    started.on('data', (data) => {
      const exp = expected.shift();
      chai.expect(exp[0]).to.equal('started');
      chai.expect(data).to.equal(exp[1]);
      if (!expected.length) {
        done();
      }
    });
    value.on('data', (data) => {
      const exp = expected.shift();
      chai.expect(exp[0]).to.equal('value');
      chai.expect(data).to.be.least(exp[1]);
      chai.expect(data).to.be.most(0.01);
      if (!expected.length) {
        done();
      }
    });

    duration.send(1000);
    start.send(true);
    tick.send(true);
  }));
});
