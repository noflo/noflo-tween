describe('Ease component', () => {
  let c = null;
  let from = null;
  let to = null;
  let type = null;
  let ins = null;
  let out = null;
  before(function (done) {
    this.timeout(4000);
    const loader = new noflo.ComponentLoader(baseDir);
    loader.load('tween/Ease', (err, instance) => {
      if (err) {
        done(err);
        return;
      }
      c = instance;
      from = noflo.internalSocket.createSocket();
      to = noflo.internalSocket.createSocket();
      ins = noflo.internalSocket.createSocket();
      c.inPorts.from.attach(from);
      c.inPorts.to.attach(to);
      c.inPorts.in.attach(ins);
      done();
    });
  });
  beforeEach(() => {
    out = noflo.internalSocket.createSocket();
    c.outPorts.out.attach(out);
  });
  afterEach(() => c.outPorts.out.detach(out));

  describe('with default linear', () => it('should get a linear response', (done) => {
    const expected = [
      0,
      500,
      1000,
    ];
    out.on('data', (data) => {
      chai.expect(data).to.equal(expected.shift());
      if (!expected.length) {
        done();
      }
    });
    from.send(0);
    to.send(1000);
    ins.send(0);
    ins.send(0.5);
    ins.send(1.0);
  }));
  describe('with in-cube', () => {
    before(() => {
      type = noflo.internalSocket.createSocket();
      c.inPorts.type.attach(type);
    });
    after(() => {
      c.inPorts.type.detach(type);
      type = null;
    });
    it('should get a in-cube response', (done) => {
      const expected = [
        0,
        0.5 * 0.5 * 0.5 * 1000,
        1000,
      ];
      out.on('data', (data) => {
        chai.expect(data).to.equal(expected.shift());
        if (!expected.length) {
          done();
        }
      });
      type.send('in-cube');
      from.send(0);
      to.send(1000);
      ins.send(0);
      ins.send(0.5);
      ins.send(1.0);
    });
  });
});
