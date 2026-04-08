import 'icon_switcher_platform_interface.dart';

IconSwitcherPlatform createWebPlatform() =>
    throw UnsupportedError('Web platform is not supported on this target.');

Future<bool> changeFaviconImpl(String faviconUrl) =>
    throw UnsupportedError('changeFavicon is not supported on this target.');

Future<bool> resetFaviconImpl() =>
    throw UnsupportedError('resetFavicon is not supported on this target.');
