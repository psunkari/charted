//
// Copyright 2014 Google Inc. All rights reserved.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd
//

part of charted.core.utils;

/// Basic namespace handing for Charted - includes utilities to
/// parse the namespace prefixes and to create DOM elements using a
/// namespace.
class Namespace {
  /// List of supported namespace prefixes.
  static const NAMESPACE_PREFIXES = const [
    'svg',
    'xhtml',
    'xlink',
    'xml',
    'xmlns'
  ];

  /// List of supported namespaces (in the same order as their prefixes)
  static const NAMESPACES = const [
    "http://www.w3.org/2000/svg",
    "http://www.w3.org/1999/xhtml",
    "http://www.w3.org/1999/xlink",
    "http://www.w3.org/XML/1998/namespace",
    "http://www.w3.org/2000/xmlns/"
  ];

  /// Create an element from [tag]. If tag is prefixed with a
  /// supported namespace prefix, the created element will
  /// have the namespaceUri set to the correct URI.
  static Element createChildElement(String tag, Element parent) {
    var separatorIndex = tag.indexOf(':');
    if (separatorIndex == -1 && parent != null) {
      return parent.ownerDocument.createElementNS(parent.namespaceUri, tag);
    }
    Namespace parsed = new Namespace._internal(tag, separatorIndex);
    return parsed.namespaceUri == null
        ? parent.ownerDocument.createElementNS(parent.namespaceUri, tag)
        : parent.ownerDocument
            .createElementNS(parsed.namespaceUri, parsed.localName);
  }

  /// Local part of the Element's tag name.
  String localName;

  /// Name space URI for the selected namespace.
  String namespaceUri;

  /// Parses a tag for namespace prefix and local name.
  /// If a known namespace prefix is found, sets the namespaceUri property
  /// to the URI of the namespace.
  factory Namespace(String tagName) =>
      new Namespace._internal(tagName, tagName.indexOf(':'));

  /// Utility for use by createChildElement and factory constructor.
  Namespace._internal(String tagName, int separatorIdx) {
    String prefix = tagName;
    if (separatorIdx >= 0) {
      prefix = tagName.substring(0, separatorIdx);
      localName = tagName.substring(separatorIdx + 1);

      var prefixIdx = NAMESPACE_PREFIXES.indexOf(prefix);
      if (prefixIdx >= 0) {
        namespaceUri = NAMESPACES.elementAt(prefixIdx);
      }
    }
    if (namespaceUri == null) localName = tagName;
  }
}
