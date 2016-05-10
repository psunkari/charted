//
// Copyright 2014 Google Inc. All rights reserved.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd
//

library charted.charts.cartesian.behaviors.axis_label_tooltip;

import 'dart:html' show Element, MouseEvent;
import 'dart:async';
import 'dart:math' as math;

import 'package:charted/charts/cartesian.dart';
import 'package:charted/core/utils.dart';
import 'package:charted/selection/selection.dart';

/// A behavior that draws marking lines on the chart.
class AxisLabelTooltip implements ChartBehavior {
  static const _AXIS_SELECTOR = '.measure-axis-group,.dimension-axis-group';

  SubscriptionsDisposer _disposer = new SubscriptionsDisposer();
  StreamSubscription _axesChangeSubscription;
  CartesianChartArea _area;
  Element _tooltipRoot;

  math.Rectangle _hostAreaRect;
  math.Rectangle _renderAreaRect;

  void init(ChartArea area, Selection upper, Selection lower) {
    if (area is! CartesianChartArea) return;
    _area = area;
    _axesChangeSubscription =
        _area.onChartAxesUpdated.listen((_) => _subscribe());

    // Axis tooltip requires host to be position: relative.
    area.host.style.position = 'relative';
  }

  void dispose() {
    _disposer.dispose();
    if (_tooltipRoot != null) _tooltipRoot.remove();
  }

  void _subscribe() {
    var elements = _area.host.querySelectorAll(_AXIS_SELECTOR);
    _disposer.dispose();
    _disposer
        .addAll(elements.map((x) => x.onMouseOver.listen(_handleMouseOver)));
    _disposer.addAll(elements.map((x) => x.onMouseOut.listen(_handleMouseOut)));
  }

  void _handleMouseOver(MouseEvent e) {
    Element target = e.target;
    if (!target.dataset.containsKey('detail')) return;
    ensureTooltipRoot();
    ensureRenderAreaRect();

    _tooltipRoot.text = target.dataset['detail'];
    var position = computeTooltipPosition(target.getBoundingClientRect(),
        _tooltipRoot.getBoundingClientRect(), _renderAreaRect);

    _tooltipRoot.style
      ..left = '${position.x}px'
      ..top = '${position.y}px'
      ..opacity = '1'
      ..visibility = 'visible';
  }

  void _handleMouseOut(MouseEvent e) {
    Element target = e.target;
    if (!target.dataset.containsKey('detail')) return;
    if (_tooltipRoot != null) {
      _tooltipRoot.style
        ..opacity = '0'
        ..visibility = 'hidden';
    }
  }

  void ensureTooltipRoot() {
    if (_tooltipRoot == null) {
      _tooltipRoot = new Element.tag('div')
        ..style.position = 'absolute'
        ..attributes['dir'] = _area.config.isRTL ? 'rtl' : ''
        ..classes.add('chart-axis-label-tooltip');
      if (_area.config.isRTL) {
        _tooltipRoot.classes.add('rtl');
      } else {
        _tooltipRoot.classes.remove('rtl');
      }
      _area.host.append(_tooltipRoot);
    }
  }

  void ensureRenderAreaRect() {
    var layout = _area.layout;
    _hostAreaRect = _area.host.getBoundingClientRect();
    _renderAreaRect = new math.Rectangle(
        _hostAreaRect.left + layout.chartArea.x + layout.renderArea.x,
        _hostAreaRect.top + layout.chartArea.y + layout.renderArea.y,
        layout.renderArea.width,
        layout.renderArea.height);
  }

  /// Computes the ideal tooltip position based on orientation.
  math.Point computeTooltipPosition(
      math.Rectangle label, math.Rectangle tooltip, math.Rectangle renderArea) {
    var x = label.left + (label.width - tooltip.width) / 2,
        y = label.top + (label.height - tooltip.height) / 2;

    if (x + tooltip.width > renderArea.right) {
      x = renderArea.right - tooltip.width;
    } else if (x < renderArea.left) {
      x = renderArea.left;
    }

    if (y + tooltip.height > renderArea.bottom) {
      y = renderArea.bottom - tooltip.height;
    } else if (y < renderArea.top) {
      y = renderArea.top;
    }

    return new math.Point(x - _hostAreaRect.left, y - _hostAreaRect.top);
  }
}
