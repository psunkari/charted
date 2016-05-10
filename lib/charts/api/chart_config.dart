//
// Copyright 2014,2015 Google Inc. All rights reserved.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd
//

part of charted.charts.api;

///
/// A [ChartSeries] represents one or more columns in ChartData that are
/// rendered together.
///
/// Examples:
/// 1. For bar-chart or line-chart, a series consists of one column
/// 2. For stacked chart or grouped bar chart, a series has more than columns
///
abstract class ChartSeries {
  /// Name of the series
  String get name;

  /// Optional Ids of measure axes.
  ///
  /// When specified renderers scale the column values against the ranges
  /// of the given axes. If an axis with a matching Id does not exist in
  /// [ChartArea] a new axis is created.
  ///
  /// When not specified, renderers may use [ChartArea.defaultMeasureAxis]
  /// where ever necessary.  Refer to the implementation of [CartesianRenderer]
  /// for more information on defaults and how the measure axes are used.
  Iterable<String> get measureAxisIds;

  /// List of columns in ChartData that are measures of this series.
  ///
  /// A series may include more than one measure if the renderer supports it.
  /// When there are more measures than what the renderer can handle, a renderer
  /// only renders the first "supported number" of columns. If the number of
  /// columns is less than the minimum that the renderer supports, the remaining
  /// measures are assumed to have zeros.
  Iterable<int> get measures;

  /// Instance of the renderer used to render the series.
  ///
  /// [ChartArea] creates a renderer using [ChartRender.create] and uses it
  /// to compute range of the measure axis and to render the chart.
  ChartRenderer get renderer;
}

///
/// Configuration of the chart.
///
abstract class ChartConfig {
  /// List of series rendered on this chart.
  Iterable<ChartSeries> get series;

  /// List of columns that form the dimensions on the chart.
  Iterable<int> get dimensions;

  /// Instance of [ChartLegend] that is used to render legend.
  /// When not specified, the legend isn't updated.
  ChartLegend get legend;

  /// Recommended minimum size for the chart
  Rect get minimumSize;

  /// When set to true, the chart rendering changes to be more suitable for
  /// scripts that are written from right-to-left.
  bool get isRTL;

  /// Indicates if the chart has primary dimension on the left axis
  bool get isLeftAxisPrimary => false;

  /// Registers axis configuration for the axis represented by [id].
  void registerMeasureAxis(String id, ChartAxisConfig axis);

  /// User-set axis configuration for [id], null if not set.
  ChartAxisConfig getMeasureAxis(String id);

  /// Register axis configuration of the axis used for dimension [column].
  void registerDimensionAxis(int column, ChartAxisConfig axis);

  /// User set axis configuration for [column], null if not set.
  ChartAxisConfig getDimensionAxis(int column);

  /// Ids of the measure axes that are displayed. If not specified, the first
  /// two measure axes are displayed. If the list is empty, none of the measure
  /// axes are displayed.
  Iterable<String> get displayedMeasureAxes;

  /// Indicates if the dimension axes should be drawn on this chart. Unless set
  /// to "false", the axes are rendered.
  bool get renderDimensionAxes;

  /// Indicate if the horizontal axes and the corresponding scales should
  /// switch direction too.
  /// Example: Time scale on the X axis would progress from right to left.
  bool get switchAxesForRTL;
}

///
/// Configuration for an axis
///
abstract class ChartAxisConfig {
  /// Title for the axis
  String get title;

  /// Scale to be used with the axis
  Scale get scale;

  /// For a quantitative scale, values at which ticks should be displayed.
  /// When not specified, the ticks are based on the type of [scale] used.
  Iterable get tickValues;
}

