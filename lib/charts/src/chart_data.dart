//
// Copyright 2014 Google Inc. All rights reserved.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd
//

import 'package:charted/charts/api.dart';

class MutableChartData implements ChartData {
  Iterable<ChartColumnSpec> _columns;
  Iterable<Iterable> _rows;

  MutableChartData(
      Iterable<ChartColumnSpec> columns, Iterable<Iterable> rows) {
    this.columns = columns;
    this.rows = rows;
  }

  set columns(Iterable<ChartColumnSpec> value) {
    assert(value != null);
    this._columns = new List<ChartColumnSpec>.from(value);
  }

  Iterable<ChartColumnSpec> get columns => _columns;

  set rows(Iterable<Iterable> value) {
    assert(value != null);
    this._rows = value;
  }

  Iterable<Iterable> get rows => _rows;
}

