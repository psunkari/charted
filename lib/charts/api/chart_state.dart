//
// Copyright 2014, 2015 Google Inc. All rights reserved.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd
//

part of charted.charts.api;

///
/// Model to provide highlight, selection and visibility in a ChartArea.
/// Selection and visibility
///
class ChartState extends ChangeNotifier {
  static int COL_SELECTED = 0x001;
  static int COL_NOT_SELECTED = 0x002;
  static int COL_PREVIEW = 0x004;
  static int COL_HIDDEN = 0x008;
  static int COL_HIGHLIGHTED = 0x010;
  static int COL_NOT_HIGHLIGHTED = 0x020;
  static int COL_HOVERED = 0x040;
  static int VAL_HIGHLIGHTED = 0x080;
  static int VAL_NOT_HIGHLIGHTED = 0x100;
  static int VAL_HOVERED = 0x200;

  static const COL_SELECTED_CLASS = 'col-selected';
  static const COL_NOT_SELECTED_CLASS = 'col-un-selected';
  static const COL_PREVIEW_CLASS = 'col-previewed';
  static const COL_HIDDEN_CLASS = 'col-hidden';
  static const COL_HIGHLIGHTED_CLASS = 'col-highlighted';
  static const COL_NOT_HIGHLIGHTED_CLASS = 'col-not-highlighted';
  static const COL_HOVERED_CLASS = 'col-hovered';
  static const VAL_HIGHLIGHTED_CLASS = 'row-highlighted';
  static const VAL_NOT_HIGHLIGHTED_CLASS = 'row-not-highlighted';
  static const VAL_HOVERED_CLASS = 'row-hovered';

  static const COLUMN_CLASS_NAMES = const [
    COL_SELECTED_CLASS,
    COL_NOT_SELECTED_CLASS,
    COL_PREVIEW_CLASS,
    COL_HIGHLIGHTED_CLASS,
    COL_NOT_HIGHLIGHTED_CLASS,
    COL_HIDDEN_CLASS,
    COL_HOVERED_CLASS
  ];

  static const VALUE_CLASS_NAMES = const [
    COL_SELECTED_CLASS,
    COL_NOT_SELECTED_CLASS,
    COL_PREVIEW_CLASS,
    COL_HIGHLIGHTED_CLASS,
    COL_NOT_HIGHLIGHTED_CLASS,
    COL_HIDDEN_CLASS,
    COL_HOVERED_CLASS,
    VAL_HIGHLIGHTED_CLASS,
    VAL_NOT_HIGHLIGHTED_CLASS,
    VAL_HOVERED_CLASS
  ];

  StreamController _changeStreamController = new StreamController.broadcast();
  Pair<int, int> _hovered;
  int _preview;

  /// Indicates if selection is supported.
  /// When not supported, [select] and [unselect] are no-op operations.
  final bool supportColumnSelection;

  /// Indicates if preview is supported.
  /// When not supported, updating [preview] is a no-op operation.
  final bool supportColumnPreview;

  /// Indicates if value highlighting is supported.
  /// When not supported, [highlight] and [unhighlight] are no-op operations.
  final bool supportValueHighlight;

  /// Indicates if value hover is supported.
  /// When not supported updating [hovered] is a no-op operation.
  final bool supportValueHover;

  /// Indicates if multiple items can be selected at the same time. When not
  /// true, selecting an item clears previous selection.
  final bool isMultiSelect;

  /// List of selected items.
  /// - Contains a column on CartesianArea if useRowColoring is false.
  /// - Row index in all other cases.
  final LinkedHashSet<int> selection = new LinkedHashSet<int>();

  /// List of visible items.
  /// - Contains a column on CartesianArea if useRowColoring is false.
  /// - Row index in all other cases.
  final LinkedHashSet<int> hidden = new LinkedHashSet<int>();

  /// Indicates if multiple values can be highlighted at the same time. When
  /// not true, highlighting an item clears previous highlights.
  final bool isMultiHighlight;

  /// Currently highlighted value, if any, represented as column and row.
  /// Highlight is result of a click on certain value.
  final LinkedHashSet<Pair> highlights = new LinkedHashSet<Pair<int, int>>();

  /// When true, only one of selection or highlights can exist.
  final bool isSelectOrHighlight;

  /// Set currently hovered value, if any, represented as column and row.
  /// Hover is result of mouse moving over a certain value in chart.
  set hovered(Pair<int, int> value) {
    if (!this.supportValueHover) return null;
    if (value != _hovered) {
      _hovered = value;
      // notifyChange(new ChartHoverChangeRecord(_hovered));
    }
    return value;
  }

  /// Get currently hovered value, if any.
  Pair<int, int> get hovered => _hovered;

  /// Set currently previewed row or column. Hidden items can be previewed
  /// by hovering on the corresponding label in Legend
  /// - Contains a column on CartesianArea if useRowColoring is false.
  /// - Row index in all other cases.
  set preview(int value) {
    if (!this.supportColumnPreview) return null;
    if (value != _preview) {
      _preview = value;
      // notifyChange(new ChartPreviewChangeRecord(_preview));
    }
    return value;
  }

  /// Currently previewed row or column.
  int get preview => _preview;

  /// Ensure that a row or column is visible.
  bool unhide(int id) {
    if (hidden.contains(id)) {
      hidden.remove(id);
      // notifyChange(new ChartVisibilityChangeRecord(unhide: id));
    }
    return true;
  }

  /// Ensure that a row or column is invisible.
  bool hide(int id) {
    if (!hidden.contains(id)) {
      hidden.add(id);
      // notifyChange(new ChartVisibilityChangeRecord(hide: id));
    }
    return false;
  }

  /// Returns current visibility of a row or column.
  bool isVisible(int id) => !hidden.contains(id);

  /// Select a row or column.
  bool select(int id) {
    if (!this.supportColumnSelection) return false;
    if (!selection.contains(id)) {
      if (!isMultiSelect) {
        selection.clear();
      }
      if (isSelectOrHighlight) {
        highlights.clear();
      }
      selection.add(id);
      // notifyChange(new ChartSelectionChangeRecord(add: id));
    }
    return true;
  }

  /// Unselect a row or column.
  bool unselect(int id) {
    if (selection.contains(id)) {
      selection.remove(id);
      // notifyChange(new ChartSelectionChangeRecord(remove: id));
    }
    return false;
  }

  /// Returns current selection state of a row or column.
  bool isSelected(int id) => selection.contains(id);

  /// Select a row or column.
  bool highlight(int column, int row) {
    if (!this.supportValueHighlight) return false;
    if (!isHighlighted(column, row)) {
      if (!isMultiHighlight) {
        highlights.clear();
      }
      if (isSelectOrHighlight) {
        selection.clear();
      }
      var item = new Pair(column, row);
      highlights.add(item);
      // notifyChange(new ChartHighlightChangeRecord(add: item));
    }
    return true;
  }

  /// Unselect a row or column.
  bool unhighlight(int column, int row) {
    if (isHighlighted(column, row)) {
      var item = new Pair(column, row);
      highlights.remove(item);
      // notifyChange(new ChartHighlightChangeRecord(remove: item));
    }
    return false;
  }

  /// Returns current selection state of a row or column.
  bool isHighlighted(int column, int row) =>
      highlights.any((x) => x.first == column && x.last == row);

  Stream get changes => _changeStreamController.stream;

  ChartState(
      {this.supportColumnSelection: true,
      this.supportColumnPreview: true,
      this.supportValueHighlight: true,
      this.supportValueHover: true,
      this.isMultiSelect: false,
      this.isMultiHighlight: false,
      this.isSelectOrHighlight: true});
}

///
/// Implementation of [ChangeRecord], that is used to notify changes to
/// values in [ChartData].
///
class ChartSelectionChangeRecord implements ChangeRecord {
  final int add;
  final int remove;
  const ChartSelectionChangeRecord({this.add, this.remove});
}

///
/// Implementation of [ChangeRecord], that is used to notify changes to
/// values in [ChartData].
///
class ChartVisibilityChangeRecord implements ChangeRecord {
  final int unhide;
  final int hide;
  const ChartVisibilityChangeRecord({this.unhide, this.hide});
}

///
/// Implementation of [ChangeRecord], that is used to notify changes to
/// values in [ChartData].
///
class ChartHighlightChangeRecord implements ChangeRecord {
  final Pair<int, int> remove;
  final Pair<int, int> add;
  const ChartHighlightChangeRecord({this.add, this.remove});
}

///
/// Implementation of [ChangeRecord], that is used to notify changes to
/// values in [ChartData].
///
class ChartHoverChangeRecord implements ChangeRecord {
  final Pair<int, int> hovered;
  const ChartHoverChangeRecord(this.hovered);
}

///
/// Implementation of [ChangeRecord], that is used to notify changes to
/// values in [ChartData].
///
class ChartPreviewChangeRecord implements ChangeRecord {
  final int previewed;
  const ChartPreviewChangeRecord(this.previewed);
}
