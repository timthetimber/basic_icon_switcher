import 'dart:js_interop';

import 'package:web/web.dart' as web;

import 'basic_icon_switcher_platform_interface.dart';

IconSwitcherPlatform createWebPlatform() => _IconSwitcherWebPlatform();

/// Cached original favicon attributes captured before the first change.
List<({String rel, String href, String type, String sizes})>? _originalFavicons;

void _cacheOriginalFavicons() {
  if (_originalFavicons != null) return;
  _originalFavicons = [];
  final existing = web.document.querySelectorAll(
    'link[rel="icon"], link[rel="shortcut icon"]',
  );
  for (var i = 0; i < existing.length; i++) {
    final node = existing.item(i);
    if (node != null &&
        (node as JSObject).instanceOfString('HTMLLinkElement')) {
      final link = node as web.HTMLLinkElement;
      _originalFavicons!.add((
        rel: link.rel,
        href: link.href,
        type: link.type,
        sizes: link.getAttribute('sizes') ?? '',
      ));
    }
  }
}

Future<bool> changeFaviconImpl(String faviconUrl) async {
  try {
    final head = web.document.head;
    if (head == null) return false;

    // Cache the original favicons before the first change
    _cacheOriginalFavicons();

    // Remove existing favicon links
    final existing = web.document.querySelectorAll(
      'link[rel="icon"], link[rel="shortcut icon"]',
    );
    for (var i = existing.length - 1; i >= 0; i--) {
      final node = existing.item(i);
      if (node != null) node.parentNode?.removeChild(node);
    }

    // Add new favicon
    final link = web.document.createElement('link') as web.HTMLLinkElement;
    link.rel = 'icon';
    link.href = faviconUrl;
    head.append(link);

    return true;
  } catch (_) {
    return false;
  }
}

Future<bool> resetFaviconImpl() async {
  try {
    final head = web.document.head;
    if (head == null) return false;

    // Remove current favicon links
    final existing = web.document.querySelectorAll(
      'link[rel="icon"], link[rel="shortcut icon"]',
    );
    for (var i = existing.length - 1; i >= 0; i--) {
      final node = existing.item(i);
      if (node != null) node.parentNode?.removeChild(node);
    }

    // Restore the original favicon links
    if (_originalFavicons != null && _originalFavicons!.isNotEmpty) {
      for (final original in _originalFavicons!) {
        final link = web.document.createElement('link') as web.HTMLLinkElement;
        link.rel = original.rel;
        link.href = original.href;
        if (original.type.isNotEmpty) link.type = original.type;
        if (original.sizes.isNotEmpty) {
          link.setAttribute('sizes', original.sizes);
        }
        head.append(link);
      }
    }

    return true;
  } catch (_) {
    return false;
  }
}

class _IconSwitcherWebPlatform extends IconSwitcherPlatform {
  @override
  Future<bool> isSupported() async => true;

  @override
  Future<String?> getCurrentIcon() async => null;
}
