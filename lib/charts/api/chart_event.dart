//
// Copyright 2014,2015 Google Inc. All rights reserved.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd
//

part of charted.charts.api;

///
/// Class representing an event emitted by renderers and chart areas
///
abstract class ChartEvent {
  /// DOM source event that caused this event
  Event get source;

  /// ChartSeries if any on which this event occurred
  ChartSeries get series;

  /// Column in ChartData on which this event occurred
  int get column;

  /// Row in ChartData on which this event occurred
  int get row;

  /// Value from ChartData on which the event occurred
  dynamic get value;

  /// X position relative to the rendered chart
  num get chartX;

  /// Y position relative to the rendered chart
  num get chartY;
}
