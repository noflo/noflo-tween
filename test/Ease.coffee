test = require "noflo-test"

test.component("tween/Ease").
  discuss("Ease default linear").
    send.data("from", 0).
    send.disconnect("from").
    send.data("to", 1000).
    send.disconnect("to").
    send.data("in", 0).
    send.disconnect("in").
    send.data("in", 0.5).
    send.disconnect("in").
    send.data("in", 1.0).
    send.disconnect("in").
  discuss("get a linear response").
    receive.data("out", 0).
    receive.data("out", 500).
    receive.data("out", 1000).

  next().
  discuss("Ease in-cube").
    send.data("from", 0).
    send.disconnect("from").
    send.data("to", 1000).
    send.disconnect("to").
    send.data("type", "in-cube").
    send.disconnect("type").
    send.data("in", 0).
    send.disconnect("in").
    send.data("in", 0.5).
    send.disconnect("in").
    send.data("in", 1.0).
    send.disconnect("in").
  discuss("get a in-cube response").
    receive.data("out", 0).
    receive.data("out", 0.5 * 0.5 * 0.5 * 1000).
    receive.data("out", 1000).

  next().
  discuss("Ease wrong type remains linear").
    send.data("from", 0).
    send.disconnect("from").
    send.data("to", 1000).
    send.disconnect("to").
    send.data("type", "random").
    send.disconnect("type").
    send.data("in", 0).
    send.disconnect("in").
    send.data("in", 0.5).
    send.disconnect("in").
    send.data("in", 1.0).
    send.disconnect("in").
  discuss("get a linear response").
    receive.data("out", 0).
    receive.data("out", 500).
    receive.data("out", 1000).

export module
