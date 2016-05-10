//
// Copyright 2014,2015 Google Inc. All rights reserved.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd
//

part of charted.charts.api;

///
/// Base interface for all implementations of a chart drawing area.
///
/// Currently, there are two implementations of this interface
/// - CartesianChartArea for drawing charts that use axes (Eg: Bar, Line)
/// - LayoutChartArea for visualizations that don't use axes (Eg: Pie, Area)
///
abstract class ChartArea {
  /// Data used by the chart. Chart isn't updated till the next call to
  /// draw function if [autoUpdate] is set to false.
  ///
  /// Setting new value to [data] will update chart if [autoUpdate] is set.
  ChartData data;

  /// Configuration for this chart.
  /// Call [draw] to update the chart when configuration is updated.
  ChartConfig config;

  /// Theme for this chart.
  /// Call [draw] to update the chart when configuration is updated.
  ChartTheme theme;

  /// Geometry of components in this [ChartArea] for use by renderers
  /// and behavior implementations.
  ChartAreaLayout get layout;

  /// Host element of the ChartArea
  Element get host;

  /// True when all components of the chart have been updated - either already
  /// drawn or are in the process of transitioning in.
  bool get isReady;

  /// When true, [ChartArea] and renderers that support coloring by row,
  /// use row indices and values to color the chart. Defaults to false.
  bool get useRowColoring;

  /// State of the chart - selection and highlights.
  ChartState get state;

  /// Stream to notify when a mouse button is pressed on [ChartArea].
  Stream<ChartEvent> get onMouseDown;

  /// Stream to notify when a pressed mouse button is released on [ChartArea].
  Stream<ChartEvent> get onMouseUp;

  /// Stream to notify when mouse pointer enters [ChartArea].
  Stream<ChartEvent> get onMouseOver;

  /// Stream to notify when mouse pointer leaves [ChartArea].
  Stream<ChartEvent> get onMouseOut;

  /// Stream of events that notify when mouse is moved on [ChartArea].
  Stream<ChartEvent> get onMouseMove;

  /// Stream to notify when a rendered value is clicked.
  Stream<ChartEvent> get onValueClick;

  /// Stream to notify when user moves mouse over a rendered value
  Stream<ChartEvent> get onValueMouseOver;

  /// Stream to notify when user moves mouse out of rendered value
  Stream<ChartEvent> get onValueMouseOut;

  /// A pane that is rendered below all the chart elements - for use with
  /// behaviors that add elements to chart.
  Selection get lowerBehaviorPane;

  /// A pane that is rendered above all the chart elements - for use with
  /// behaviors that add elements to chart.
  Selection get upperBehaviorPane;

  /// Add a behavior to the chart.
  void addChartBehavior(ChartBehavior behavior);

  /// Remove a behavior from the chart.
  void removeChartBehavior(ChartBehavior behavior);

  /// Draw the chart with current data and configuration.
  /// - If [preRender] is set, [ChartArea] attempts to build all non data
  ///   dependant elements of the chart.
  /// - When [schedulePostRender] is not null, non-essential elements/tasks
  ///   of chart building are postponed until the future is resolved.
  void draw({bool preRender: false, Future schedulePostRender});

  /// Force destroy the ChartArea.
  /// - Clear references to all passed objects and subscriptions.
  /// - Call dispose on all renderers and behaviors.
  void dispose();
}

///
/// Interface that is used to pass layout and geometry of the chart to
/// renderers and behavior implementations.
///
abstract class ChartAreaLayout {
  /// Layout of the axes by orientation
  Map<Orientation, Rect> get axes;

  /// Layout of the rendering area.
  /// In case of cartesian charts, this is [chartArea] without the area used
  /// by all axes.  In case of layout charts, this is same as [chartArea].
  Rect get renderArea;

  /// Area used by the chart.
  Rect get chartArea;
}

