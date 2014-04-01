test = require "noflo-test"

test.component("tween/Timeline").
  discuss("Start a timeline").
    send.data("start", true).
    send.disconnect("start").
    send.data("duration", 1000).
    send.disconnect("duration").
    send.data("tick", true).
    send.disconnect("tick").
  discuss("get a started output & value = 0").
    receive.data("started", true).
    receive.data("value", 0.0).


  next().
  discuss("Start a reverse timeline").
    send.data("start", true).
    send.disconnect("start").
    send.data("reverse", true).
    send.disconnect("reverse").
    send.data("duration", 1000).
    send.disconnect("duration").
    send.data("tick", true).
    send.disconnect("tick").
  discuss("get a started output & value = 1").
    receive.data("started", true).
    receive.data("value", 1.0).

  next().
  discuss("Start/Stop a timeline").
    send.data("start", true).
    send.disconnect("start").
    send.data("reverse", true).
    send.disconnect("reverse").
    send.data("duration", 1000).
    send.disconnect("duration").
    send.data("tick", true).
    send.disconnect("tick").
    send.data("stop", true).
    send.disconnect("stop").
  discuss("get a started output & value = 1").
    receive.data("started", true).
    receive.data("value", 0.0).
    receive.data("stopped", true).

  next().
  discuss("Start and pause a timeline").
    send.data("start", true).
    send.disconnect("start").
    send.data("reverse", true).
    send.disconnect("reverse").
    send.data("duration", 1000).
    send.disconnect("duration").
    send.data("tick", true).
    send.disconnect("tick").
    send.data("pause", true).
    send.disconnect("pause").
  discuss("get a started output & value = 1").
    receive.data("started", true).
    receive.data("value", 0.0).
    receive.data("paused", true).

  next().
  discuss("Start, pause and unpause a timeline").
    send.data("start", true).
    send.disconnect("start").
    send.data("reverse", true).
    send.disconnect("reverse").
    send.data("duration", 1000).
    send.disconnect("duration").
    send.data("tick", true).
    send.disconnect("tick").
    send.data("pause", true).
    send.disconnect("pause").
    send.data("unpause", true).
    send.disconnect("unpause").
  discuss("get a started output & value = 1").
    receive.data("started", true).
    receive.data("value", 0.0).
    receive.data("paused", true).
    receive.data("unpaused", true).

  next().
  discuss("Timeline doesn't tick while stopped").
    send.data("start", true).
    send.disconnect("start").
    send.data("duration", 1000).
    send.disconnect("duration").
    send.data("tick", true).
    send.disconnect("tick").
    send.data("stop", true).
    send.disconnect("stop").
    send.data("tick", true).
    send.disconnect("tick").
    send.data("reverse", true).
    send.disconnect("reverse").
    send.data("start", true).
    send.disconnect("start").
    send.data("tick", true).
    send.disconnect("tick").
  discuss("get a started output & value = 1").
    receive.data("started", true).
    receive.data("value", 0.0).
    receive.data("stopped", true).
    receive.data("started", true).
    receive.data("value", 1.0).

export module
