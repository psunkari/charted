
library charted.benchmarks;

import 'dart:html';

class BenchmarkResult {
  final int totalMicroSeconds;
  final int count;
  final int runtime;
  BenchmarkResult(int totalMicroSeconds, int count)
      : totalMicroSeconds = totalMicroSeconds,
        count = count,
        runtime = totalMicroSeconds ~/ count;
  @override
  toString() => 'runtime: ${runtime}us ($totalMicroSeconds / $count)';
}

abstract class BenchmarkBase {
  final String name;

  const BenchmarkBase(String name) : this.name = name;

  void run();
  void setUp() { }
  void tearDown() { }

  BenchmarkResult measureFor(int cyclesCount, int minCycleCount) {
    int totalRunTime = 0,
        count = 0;

    while(count < cyclesCount) {
      for (int i = 0; i < minCycleCount; ++i) {
        setUp();

        var start = window.performance.now();
        run();
        totalRunTime += ((window.performance.now() - start) * 1000).floor();

        tearDown();
        count++;
      }
    }

    return new BenchmarkResult(totalRunTime, count);
  }

  BenchmarkResult measure() {
    measureFor(2, 1);
    return measureFor(100, 10);
  }

  void report() {
    print('$name ${measure()}');
  }

}
