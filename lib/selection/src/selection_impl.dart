/*
 * Copyright 2014 Google Inc. All rights reserved.
 *
 * Use of this source code is governed by a BSD-style
 * license that can be found in the LICENSE file or at
 * https://developers.google.com/open-source/licenses/bsd
 */
part of charted.selection;

/**
 * Implementation of [Selection].
 * Selections cannot be created directly - they are only created using
 * the select or selectAll methods on [SelectionScope] and [Selection].
 */
class _SelectionImpl implements Selection {
  List<SelectionGroup> groups;
  SelectionScope scope;

  /**
   * Creates a new selection.
   *
   * When [source] is not specified, the new selection would have exactly
   * one group with [SelectionScope.root] as it's parent.  Otherwise, one group
   * per for each non-null element is created with element as it's parent.
   *
   * When [selector] is specified, each group contains all elements matching
   * [selector] and under the group's parent element.  Otherwise, [fn] is
   * called once per group with parent element's "data", "index" and the
   * "element" itself passed as parameters.  [fn] must return an iterable of
   * elements to be used in each group.
   */
  _SelectionImpl.all(String selector, {this.scope, Selection source}) {
    assert(!isNullOrEmpty(selector));
    assert(source != null || scope != null);
    assert(source == null || scope == null);

    var tmpGroups = <SelectionGroup>[];
    if (source != null) {
      scope = source.scope;
      for (int gi = 0; gi < source.groups.length; ++gi) {
        final g = source.groups.elementAt(gi);
        for (int ei = 0; ei < g.elements.length; ++ei) {
          final e = g.elements.elementAt(ei);
          if (e != null) {
            tmpGroups.add(new _SelectionGroupImpl(e.querySelectorAll(selector),
                parent: e));
          }
        }
      }
    } else {
      tmpGroups = [
        new _SelectionGroupImpl(scope.root.querySelectorAll(selector),
            parent: scope.root)
      ];
    }
    groups = tmpGroups;
  }

  _SelectionImpl.allWithCallback(SelectionCallback<Iterable<Element>> fn,
      {this.scope, Selection source}) {
    assert(fn != null);
    assert(source != null || scope != null);
    assert(source == null || scope == null);

    var tmpGroups = <SelectionGroup>[];
    if (source != null) {
      scope = source.scope;
      for (int gi = 0; gi < source.groups.length; ++gi) {
        final g = source.groups.elementAt(gi);
        for (int ei = 0; ei < g.elements.length; ++ei) {
          final e = g.elements.elementAt(ei);
          if (e != null) {
            tmpGroups.add(
                new _SelectionGroupImpl(fn(scope.datum(e), gi, e), parent: e));
          }
        }
      }
    } else {
      tmpGroups = [
        new _SelectionGroupImpl(fn(null, 0, null), parent: scope.root)
      ];
    }
    groups = tmpGroups;
  }

  /**
   * Same as [all] but only uses the first element matching [selector] when
   * [selector] is specified.  Otherwise, call [fn] which must return the
   * element to be selected.
   */
  _SelectionImpl.single(String selector, {this.scope, Selection source}) {
    assert(!isNullOrEmpty(selector));
    assert(source != null || scope != null);
    assert(source == null || scope == null);

    if (source != null) {
      scope = source.scope;
      groups = source.groups
          .map((SelectionGroup g) => new _SelectionGroupImpl(
              g.elements.map((Element e) {
                if (e == null) return null;
                var datum = scope.datum(e);
                var selected = e.querySelector(selector);
                scope.associate(selected, datum);
                return selected;
              }).toList(growable: false),
              parent: g.parent))
          .toList(growable: false);
    } else {
      groups = <SelectionGroup>[
        new _SelectionGroupImpl([scope.root.querySelector(selector)])
      ];
    }
  }

  _SelectionImpl.singleWithCallback(SelectionCallback<Element> fn,
      {this.scope, Selection source}) {
    assert(fn != null);
    assert(source != null || scope != null);
    assert(source == null || scope == null);

    if (source != null) {
      scope = source.scope;
      groups = source.groups
          .map((SelectionGroup g) => new _SelectionGroupImpl(
              new List.generate(g.elements.length, (ei) {
                var e = g.elements.elementAt(ei);
                if (e == null) return null;
                var datum = scope.datum(e);
                var selected = fn(datum, ei, e);
                scope.associate(selected, datum);
                return selected;
              }),
              parent: g.parent))
          .toList(growable: false);
    } else {
      groups = <SelectionGroup>[
        new _SelectionGroupImpl([fn(null, 0, null)])
      ];
    }
  }

  /** Creates a selection using the pre-computed list of [SelectionGroup] */
  _SelectionImpl.selectionGroups(this.groups, this.scope);

  /**
   * Creates a selection using the list of elements. All elements will
   * be part of the same group, with [SelectionScope.root] as the group's parent
   */
  _SelectionImpl.elements(Iterable elements, this.scope) {
    groups = <SelectionGroup>[new _SelectionGroupImpl(elements.toList())];
  }

  /** Calls a function on each non-null element in the selection */
  void each(SelectionCallback fn) {
    assert(fn != null);
    for (int gi = 0, gLen = groups.length; gi < gLen; ++gi) {
      final g = groups.elementAt(gi);
      for (int ei = 0, eLen = g.elements.length; ei < eLen; ++ei) {
        final e = g.elements.elementAt(ei);
        if (e != null) fn(scope.datum(e), ei, e);
      }
    }
  }

  void forEachElement(void fn(Element element)) {
    assert(fn != null);
    for (int gi = 0, gLen = groups.length; gi < gLen; ++gi) {
      final g = groups.elementAt(gi);
      for (int ei = 0, eLen = g.elements.length; ei < eLen; ++ei) {
        final e = g.elements.elementAt(ei);
        if (e != null) fn(e);
      }
    }
  }

  void on(String type, [SelectionCallback listener, bool capture]) {
    EventListener getEventHandler(i, e) => (Event event) {
          var previous = scope.event;
          scope.event = event;
          try {
            listener(scope.datum(e), i, e);
          } finally {
            scope.event = previous;
          }
        };

    if (!type.startsWith('.')) {
      if (listener != null) {
        // Add a listener to each element.
        each((d, i, Element e) {
          var handlers = scope._listeners[e];
          if (handlers == null) scope._listeners[e] = handlers = {};
          handlers[type] = new Pair(getEventHandler(i, e), capture);
          e.addEventListener(type, handlers[type].first, capture);
        });
      } else {
        // Remove the listener from each element.
        each((d, i, Element e) {
          var handlers = scope._listeners[e];
          if (handlers != null && handlers[type] != null) {
            e.removeEventListener(
                type, handlers[type].first, handlers[type].last);
          }
        });
      }
    } else {
      // Remove all listeners on the event type (ignoring the namespace)
      each((d, i, Element e) {
        var handlers = scope._listeners[e], t = type.substring(1);
        handlers.forEach((String s, Pair<EventListener, bool> value) {
          if (s.split('.')[0] == t) {
            e.removeEventListener(s, value.first, value.last);
          }
        });
      });
    }
  }

  int get length {
    int retval = 0;
    forEachElement((e) => retval++);
    return retval;
  }

  bool get isEmpty => length == 0;

  /** First non-null element in this selection */
  Element get first {
    for (int gi = 0; gi < groups.length; gi++) {
      SelectionGroup g = groups.elementAt(gi);
      for (int ei = 0; ei < g.elements.length; ei++) {
        if (g.elements.elementAt(ei) != null) {
          return g.elements.elementAt(ei);
        }
      }
    }
    return null;
  }

  void _attrAction(Element e, String v, String name) {
    v == null ? e.attributes.remove(name) : e.setAttribute(name, v);
  }

  void attr(String name, String val) {
    assert(name != null && name.isNotEmpty);
    forEachElement((e) => _attrAction(e, val, name));
  }

  void attrWithCallback(String name, SelectionCallback fn) {
    assert(fn != null);
    each((d, i, e) => _attrAction(e, fn(d, i, e), name));
  }

  void _classedAction(Element e, bool add, String name) {
    add == false ? e.classes.remove(name) : e.classes.add(name);
  }

  void classed(String name, [bool val = true]) {
    assert(name != null && name.isNotEmpty);
    forEachElement((e) => _classedAction(e, val, name));
  }

  void classedWithCallback(String name, SelectionCallback<bool> fn) {
    assert(fn != null);
    each((d, i, e) => _classedAction(e, fn(d, i, e), name));
  }

  void _styleAction(Element e, String value, String property, String priority) {
    isNullOrEmpty(value)
        ? e.style.removeProperty(property)
        : e.style.setProperty(property, value, priority);
  }

  void style(String property, String val, {String priority}) {
    assert(property != null && property.isNotEmpty);
    forEachElement((e) => _styleAction(e, val, property, priority));
  }

  void styleWithCallback(String property, SelectionCallback<String> fn,
      {String priority}) {
    assert(fn != null);
    each((d, i, e) => _styleAction(e, fn(d, i, e), property, priority));
  }

  void _textAction(Element e, String v) {
    e.text = v == null ? '' : v;
  }

  void text(String val) {
    forEachElement((e) => _textAction(e, val));
  }

  void textWithCallback(SelectionCallback<String> fn) {
    assert(fn != null);
    each((d, i, e) => _textAction(e, fn(d, i, e)));
  }

  void _htmlAction(Element e, String v) {
    e.innerHtml = v == null ? '' : v;
  }

  void html(String val) {
    forEachElement((e) => _htmlAction(e, val));
  }

  void htmlWithCallback(SelectionCallback<String> fn) {
    assert(fn != null);
    each((d, i, e) => _htmlAction(e, fn(d, i, e)));
  }

  void remove() => forEachElement((e) => e.remove());

  Selection select(String selector) {
    assert(selector != null && selector.isNotEmpty);
    return new _SelectionImpl.single(selector, source: this);
  }

  Selection selectWithCallback(SelectionCallback<Element> fn) {
    assert(fn != null);
    return new _SelectionImpl.singleWithCallback(fn, source: this);
  }

  Selection append(String tag) {
    assert(tag != null && tag.isNotEmpty);
    Element specimen;
    return new _SelectionImpl.singleWithCallback((datum, ei, e) {
      Element child = specimen == null
          ? specimen = Namespace.createChildElement(tag, e)
          : specimen.clone(false);
      return e.append(child);
    }, source: this);
  }

  Selection appendWithCallback(SelectionCallback<Element> fn) {
    assert(fn != null);
    return new _SelectionImpl.singleWithCallback((datum, ei, e) {
      Element child = fn(datum, ei, e);
      return child == null ? null : e.append(child);
    }, source: this);
  }

  Selection insert(String tag,
      {String before, SelectionCallback<Element> beforeFn}) {
    assert(tag != null && tag.isNotEmpty);
    return insertWithCallback(
        (d, ei, e) => Namespace.createChildElement(tag, e),
        before: before,
        beforeFn: beforeFn);
  }

  Selection insertWithCallback(SelectionCallback<Element> fn,
      {String before, SelectionCallback<Element> beforeFn}) {
    assert(fn != null);
    beforeFn =
        before == null ? beforeFn : (d, ei, e) => e.querySelector(before);
    return new _SelectionImpl.singleWithCallback((datum, ei, e) {
      Element child = fn(datum, ei, e);
      Element before = beforeFn(datum, ei, e);
      return child == null ? null : e.insertBefore(child, before);
    }, source: this);
  }

  Selection selectAll(String selector) {
    assert(selector != null && selector.isNotEmpty);
    return new _SelectionImpl.all(selector, source: this);
  }

  Selection selectAllWithCallback(SelectionCallback<Iterable<Element>> fn) {
    assert(fn != null);
    return new _SelectionImpl.allWithCallback(fn, source: this);
  }

  DataSelection data(Iterable vals, [SelectionKeyFunction keyFn]) {
    assert(vals != null);
    return dataWithCallback(toCallback(vals), keyFn);
  }

  // Create a dummy node to be used with enter() selection.
  Object _dummyElement(val) {
    var element = new Object();
    scope.associate(element, val);
    return element;
  }

  DataSelection dataWithCallback(SelectionCallback<Iterable> fn,
      [SelectionKeyFunction keyFn]) {
    assert(fn != null);

    var enterGroups = <SelectionGroup>[],
        updateGroups = <SelectionGroup>[],
        exitGroups = <SelectionGroup>[];

    // Joins data to all elements in the group.
    void join(SelectionGroup g, Iterable vals) {
      final int valuesLength = vals.length;
      final int elementsLength = g.elements.length;

      // Nodes exiting, entering and updating in this group.
      // We maintain the nodes at the same index as they currently
      // are (for exiting) or where they should be (for entering and updating)
      final update = new List(valuesLength);
      final enter = new List(valuesLength);
      final exit = new List(elementsLength);

      // Use key function to determine DOMElement to data associations.
      if (keyFn != null) {
        var keysOnDOM = [], elementsByKey = {}, valuesByKey = {};

        // Create a key to DOM element map.
        // Used later to see if an element already exists for a key.
        for (int ei = 0, len = elementsLength; ei < len; ++ei) {
          final e = g.elements.elementAt(ei);
          if (e != null) {
            var keyValue = keyFn(scope.datum(e));
            if (elementsByKey.containsKey(keyValue)) {
              exit[ei] = e;
            } else {
              elementsByKey[keyValue] = e;
            }
            keysOnDOM.add(keyValue);
          }
        }

        // Iterate through the values and find values that don't have
        // corresponding elements in the DOM, collect the entering elements.
        for (int vi = 0, len = valuesLength; vi < len; ++vi) {
          final v = vals.elementAt(vi);
          var keyValue = keyFn(v);
          Element e = elementsByKey[keyValue];
          if (e != null) {
            update[vi] = e;
            scope.associate(e, v);
          } else if (!valuesByKey.containsKey(keyValue)) {
            enter[vi] = _dummyElement(v);
          }
          valuesByKey[keyValue] = v;
          elementsByKey.remove(keyValue);
        }

        // Iterate through the previously saved keys to
        // find a list of elements that don't have data anymore.
        // We don't use elementsByKey.keys() because that does not
        // guarantee the order of returned keys.
        for (int i = 0, len = elementsLength; i < len; ++i) {
          if (elementsByKey.containsKey(keysOnDOM[i])) {
            exit[i] = g.elements.elementAt(i);
          }
        }
      } else {
        // When we don't have the key function, just use list index as the key
        int updateElementsCount = math.min(elementsLength, valuesLength);
        int i = 0;

        // Collect a list of elements getting updated in this group
        for (int len = updateElementsCount; i < len; ++i) {
          var e = g.elements.elementAt(i);
          if (e != null) {
            scope.associate(e, vals.elementAt(i));
            update[i] = e;
          } else {
            enter[i] = _dummyElement(vals.elementAt(i));
          }
        }

        // List of elements newly getting added
        for (int len = valuesLength; i < len; ++i) {
          enter[i] = _dummyElement(vals.elementAt(i));
        }

        // List of elements exiting this group
        for (int len = elementsLength; i < len; ++i) {
          exit[i] = g.elements.elementAt(i);
        }
      }

      // Create the element groups and set parents from the current group.
      enterGroups.add(new _SelectionGroupImpl(enter, parent: g.parent));
      updateGroups.add(new _SelectionGroupImpl(update, parent: g.parent));
      exitGroups.add(new _SelectionGroupImpl(exit, parent: g.parent));
    }
    ;

    for (int gi = 0; gi < groups.length; ++gi) {
      final g = groups.elementAt(gi);
      join(g, fn(scope.datum(g.parent), gi, g.parent));
    }

    return new _DataSelectionImpl(updateGroups, enterGroups, exitGroups, scope);
  }

  void datum(Iterable vals) {
    throw new UnimplementedError();
  }

  void datumWithCallback(SelectionCallback<Iterable> fn) {
    throw new UnimplementedError();
  }

  Transition transition() => new Transition(this);
}

/* Implementation of [DataSelection] */
class _DataSelectionImpl extends _SelectionImpl implements DataSelection {
  EnterSelection enter;
  ExitSelection exit;

  _DataSelectionImpl(
      List<SelectionGroup> updated,
      Iterable<SelectionGroup> entering,
      Iterable<SelectionGroup> exiting,
      SelectionScope scope)
      : super.selectionGroups(updated, scope) {
    enter = new _EnterSelectionImpl(entering, this);
    exit = new _ExitSelectionImpl(exiting, this);
  }
}

/* Implementation of [EnterSelection] */
class _EnterSelectionImpl implements EnterSelection {
  final DataSelection update;

  SelectionScope scope;
  Iterable<SelectionGroup> groups;

  _EnterSelectionImpl(this.groups, this.update) {
    scope = update.scope;
  }

  bool get isEmpty => false;

  Selection insert(String tag,
      {String before, SelectionCallback<Element> beforeFn}) {
    assert(tag != null && tag.isNotEmpty);
    return insertWithCallback(
        (d, ei, e) => Namespace.createChildElement(tag, e),
        before: before,
        beforeFn: beforeFn);
  }

  Selection insertWithCallback(SelectionCallback<Element> fn,
      {String before, SelectionCallback<Element> beforeFn}) {
    assert(fn != null);
    return selectWithCallback((d, ei, e) {
      Element child = fn(d, ei, e);
      e.insertBefore(child, e.querySelector(before));
      return child;
    });
  }

  Selection append(String tag) {
    assert(tag != null && tag.isNotEmpty);
    Element specimen;
    return selectWithCallback((datum, ei, e) {
      Element child = specimen == null
          ? specimen = Namespace.createChildElement(tag, e)
          : specimen.clone(false);
      return e.append(child);
    });
  }

  Selection appendWithCallback(SelectionCallback<Element> fn) {
    assert(fn != null);
    return selectWithCallback((datum, ei, e) {
      Element child = fn(datum, ei, e);
      return e.append(child);
    });
  }

  Selection select(String selector) {
    assert(selector == null && selector.isNotEmpty);
    return selectWithCallback((d, ei, e) => e.querySelector(selector));
  }

  Selection selectWithCallback(SelectionCallback<Element> fn) {
    var subgroups = <SelectionGroup>[];
    for (int gi = 0, len = groups.length; gi < len; ++gi) {
      final g = groups.elementAt(gi);
      final u = update.groups.elementAt(gi);
      final subgroup = <Element>[];
      for (int ei = 0, eLen = g.elements.length; ei < eLen; ++ei) {
        final e = g.elements.elementAt(ei);
        if (e != null) {
          var datum = scope.datum(e), selected = fn(datum, ei, g.parent);
          scope.associate(selected, datum);
          u.elements[ei] = selected;
          subgroup.add(selected);
        } else {
          subgroup.add(null);
        }
      }
      subgroups.add(new _SelectionGroupImpl(subgroup, parent: g.parent));
    }
    return new _SelectionImpl.selectionGroups(subgroups, scope);
  }
}

/* Implementation of [ExitSelection] */
class _ExitSelectionImpl extends _SelectionImpl implements ExitSelection {
  final DataSelection update;
  _ExitSelectionImpl(List<SelectionGroup> groups, DataSelection update)
      : update = update,
        super.selectionGroups(groups, update.scope);
}

class _SelectionGroupImpl implements SelectionGroup {
  List<Element> elements;
  Element parent;
  _SelectionGroupImpl(this.elements, {this.parent});
}
