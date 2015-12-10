
library charted.benchmarks.line_chart;

import 'package:charted/charted.dart';
import 'dart:html';
import 'dart:math';

/// Helper method to create default behaviors for cartesian chart demos.
Iterable<ChartBehavior> createDefaultCartesianBehaviors() =>
    new List.from([new Hovercard(isMultiValue: true), new AxisLabelTooltip()]);

/// Creates a new container for chart
Element createChartWrapper() => new Element.html('''
    <div class="chart-wrapper">
        <div class="chart-host-wrapper">
            <div class="chart-host" dir="ltr"></div>
            <div class="chart-legend-host"></div>
        </div>
    </div>''', treeSanitizer: new NullTreeSanitizer());

/// Create data as a list of maps (think, list of JSON objects from the API)
List<Map<String,int>> generateChartData(
    int rowCount, int measureColumnCount, { bool allowNegative: true }) {
  const START_TIME_MS = 600000000000;
  const INCREMENT_MS = 1000 * 60 * 24;

  var RANDOM = new Random(123456);

  List<Map<String, int>> data = [];
  for (int point = 0; point < rowCount ; point++) {
    Map<String, int> value = {};
    value['domain'] = (START_TIME_MS + (INCREMENT_MS * point));
    for (int series = 0; series < measureColumnCount; series++) {
      value['m' + series.toString()] = RANDOM.nextInt(4000)
          - (allowNegative && RANDOM.nextBool() ? 2000 : 0);
    }
    data.add(value);
  }

  return data;
}

/// Extracts column data from generated chart data
List<ChartColumnSpec> generateColumnSpecs(List<Map<String,int>> data) =>
    data[0].keys.map((key) => key == "domain"
        ? new ChartColumnSpec(label:key, type: ChartColumnSpec.TYPE_TIMESTAMP)
        : new ChartColumnSpec(label:key)).toList();

/// Draw a line chart.
void line() {
  var generated = generateChartData(30, 2),
      columns = generateColumnSpecs(generated),
      data = generated.map((value) => value.values.toList()).toList(),
      outerElement = document.querySelector('#charts-container'),
      wrapper = createChartWrapper(),
      areaHost = wrapper.querySelector('.chart-host'),
      legendHost = wrapper.querySelector('.chart-legend-host');

  outerElement.append(wrapper);

  var series = new ChartSeries("one", [1, 2], new LineChartRenderer()),
      config = new ChartConfig([series], [0])..legend = new ChartLegend(legendHost),
      chartData = new ChartData(columns, data),
      state = new ChartState();

  var area = new CartesianArea(areaHost, chartData, config, state: state);
  createDefaultCartesianBehaviors().forEach((behavior) {
    area.addChartBehavior(behavior);
  });
  area.draw();
}

main() {
  document.querySelector('#benchmark-trigger').onClick.listen((_) => line());
}
