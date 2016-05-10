//
// Copyright 2014,2015 Google Inc. All rights reserved.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd
//

part of charted.charts.api;

/// Interface implemented by chart behaviors.
/// During initialization, the behaviors subscribe to any necessary events and
/// handle them appropriately.
abstract class ChartBehavior {
  /// Called while ChartArea is being initialized.
  ///  - [area] is the ChartArea on which this behavior is installed
  ///  - [upperRenderPane] is the Selection that is rendered on top of the
  ///    chart.  Behaviors can use it to draw any visualization in response
  ///    to user actions.
  ///  - [lowerRenderPane] is the Selection that is rendered below the chart.
  void init(
      ChartArea area, Selection upperRenderPane, Selection lowerRenderPane);

  /// Clears all DOM created by this behavior, unsubscribes to event listeners
  /// and clears any state.
  void dispose();
}

