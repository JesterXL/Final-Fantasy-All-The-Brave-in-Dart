// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:html';
import 'dart:core';
import 'dart:async';
import 'com/jessewarden/streamsarefun/core/streamscore.dart';
import 'com/jessewarden/streamsarefun/battle/battlecore.dart';

void main() {
  querySelector('#output').text = 'Your Dart app is running.';
  //testGameLoop();
  testBattleTimer();
}

void testGameLoop()
{
  GameLoop gameLoop = new GameLoop();
  gameLoop.stream.listen((GameLoopEvent event)
  {
    print("event: " + event.type);
  });
  gameLoop.start();
  new Future.delayed(new Duration(milliseconds: 300), ()
  {
    gameLoop.pause();
  });
  new Future.delayed(const Duration(milliseconds: 500), () {
  });
}

void testBattleTimer()
{
  GameLoop gameLoop = new GameLoop();
  BattleTimer timer = new BattleTimer(gameLoop.stream, BattleTimer.MODE_CHARACTER);
  gameLoop.start();
  timer.start();
  timer.stream
  .where((BattleTimerEvent event)
  {
    return event.type == BattleTimerEvent.PROGRESS;
  })
  .listen((BattleTimerEvent event)
  {
    print("percent: ${event.percentage}");
  });

  new Future.delayed(new Duration(milliseconds: 300), ()
  {
    gameLoop.pause();
  });
}