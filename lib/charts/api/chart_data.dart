//
// Copyright 2014,2015 Google Inc. All rights reserved.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd
//
part of charted.charts.api;

///
/// Enumeration of column types.
///
enum ChartColumnType { Boolean, Date, Number, String, Timestamp }


///
/// Interface to be implemented by providers of tabular data for chart.
///
abstract class ChartData {
  /// Read-only access to column specs
  Iterable<ChartColumnSpec> get columns;

  /// Read-only access to rows
  Iterable<Iterable> get rows;
}

///
/// Interface implemented by [ChartData] transformers.
/// Examples:
///   [FilterTransformer] to filter data
///
abstract class ChartDataTransform {
  /// Create a new instance of [ChartData] by selecting a subset
  /// of rows and columns from the current one
  ChartData transform(ChartData source);
}

///
/// Meta information for each column in ChartData
///
class ChartColumnSpec {
  static const List ORDINAL_SCALES = const [ChartColumnType.String];
  static const List LINEAR_SCALES = const [ChartColumnType.Number];
  static const List TIME_SCALES = const [
    ChartColumnType.Date,
    ChartColumnType.Timestamp
  ];

  /// Formatter for values that belong to this column
  final FormatFunction formatter;

  /// Label for the column.  Used in legend, tooltips etc;
  /// When not specified, defaults to empty string.
  final String label;

  /// Type of data in this column. Used for interpolations, computing
  /// scales and ranges. When not specified, it is assumed to be "number"
  /// for measures and "string" for dimensions.
  final ChartColumnType type;

  /// Indicates if this column requires [OrdinalScale].
  ///
  /// If not specified, an ordinal scale is used for string columns and
  /// quantitative scales are used for others.
  final bool useOrdinalScale;

  /// Initialize axis scale according to [ChartColumnSpec] type.
  /// This logic is extracted from [ChartArea] implementation for conveniently
  /// adding more scale types.
  Scale createDefaultScale() {
    if (useOrdinalScale == true) {
      return new OrdinalScale();
    } else if (LINEAR_SCALES.contains(type)) {
      return new LinearScale();
    } else if (TIME_SCALES.contains(type)) {
      return new TimeScale();
    }
    return null;
  }

  ChartColumnSpec(
      {this.label,
      ChartColumnType type: ChartColumnType.Number,
      this.formatter,
      bool useOrdinalScale})
      : useOrdinalScale = useOrdinalScale == true ||
      useOrdinalScale == null && ORDINAL_SCALES.contains(type),
        type = type;
}

