library charted.benchmarks.selection;

import 'dart:html';
import 'dart:math';

import 'package:charted/selection/selection.dart';
import 'benchmark.dart';

Iterable<Iterable<int>> generateData() {
  var random = new Random(new DateTime.now().millisecondsSinceEpoch),
      count = 100,
      data = [];
  for (int outer = 0; outer < count; outer++) {
    List<int> values = [];
    for (int inner = 0, start = random.nextInt(1000); inner < count; inner++) {
      values.add(start + inner);
    }
    data.add(values);
  }
  return data;
}

class DataJoinBenchmark extends BenchmarkBase {
  final List<List<int>> data = [];

  DataJoinBenchmark() : super('Selection.data()');

  @override
  void run() {
    new SelectionScope.selector('body').selectAll('div').data(data);
  }

  @override
  void setUp() {
    data.addAll(generateData());
  }

  @override
  void tearDown() {
    data.clear();
  }
}

class EnterAppendBenchmark extends BenchmarkBase {
  final List<List<int>> data = [];

  EnterAppendBenchmark() : super('EnterSelection.append()');

  @override
  void run() {
    var scope = new SelectionScope.selector('#benchmark-wrapper'),
        selection = scope.selectAll('div').data(data);

    selection.enter.append('div');
    selection
        .selectAll('div')
        .dataWithCallback((d, i, e) => d)
        .enter
        .append('div');
  }

  @override
  void setUp() {
    data.addAll(generateData());
  }

  @override
  void tearDown() {
    data.clear();
    document.querySelector('#benchmark-wrapper').innerHtml = '';
  }
}

main() {
  document.querySelector('#benchmark-trigger').onClick.listen((_) {
    new DataJoinBenchmark().report();
    new EnterAppendBenchmark().report();
  });
}
