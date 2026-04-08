import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:basic_icon_switcher/basic_icon_switcher.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Icon Switcher Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _currentIcon = 'default';
  String _status = '';

  @override
  void initState() {
    super.initState();
    _loadCurrentIcon();
  }

  Future<void> _loadCurrentIcon() async {
    final current = await IconSwitcher.getCurrentIcon();
    setState(() {
      _currentIcon = current ?? 'default';
    });
  }

  Future<void> _switchIcon(String name) async {
    try {
      await IconSwitcher.changeIcon(
        iconName: name,
        // Android: fully qualified activity-alias name
        androidActivityAlias:
            'com.example.example.${name[0].toUpperCase()}${name.substring(1).toLowerCase()}',
        // Web: path to favicon in web/ directory
        webFaviconUrl: 'icons/$name.png',
        // Desktop: Flutter asset path
        desktopIconAsset: 'assets/icons/$name.png',
      );
      setState(() {
        _currentIcon = name;
        _status = 'Icon changed to "$name"';
      });
    } on PlatformException catch (e) {
      setState(() {
        _status = 'Error: ${e.message}';
      });
    } on ArgumentError catch (e) {
      setState(() {
        _status = 'Error: ${e.message}';
      });
    }
  }

  Future<void> _resetIcon() async {
    try {
      await IconSwitcher.resetIcon();
      setState(() {
        _currentIcon = 'default';
        _status = 'Icon reset to default';
      });
    } on PlatformException catch (e) {
      setState(() {
        _status = 'Error: ${e.message}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Icon Switcher Demo'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Current icon: $_currentIcon',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                _platformDescription,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => _switchIcon('first'),
                child: const Text('First Icon'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => _switchIcon('second'),
                child: const Text('Second Icon'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _resetIcon,
                child: const Text('Reset Icon'),
              ),
              if (_status.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  _status,
                  style: TextStyle(
                    color:
                        _status.startsWith('Error') ? Colors.red : Colors.green,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String get _platformDescription {
    if (kIsWeb) {
      return 'Web: Changes the browser tab favicon.';
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return 'iOS: Changes the launcher icon permanently.';
      case TargetPlatform.android:
        return 'Android: Changes the launcher icon permanently.';
      case TargetPlatform.macOS:
        return 'macOS: Changes the dock icon (resets on app restart).';
      case TargetPlatform.windows:
        return 'Windows: Changes the window icon (resets on app restart).';
      case TargetPlatform.linux:
        return 'Linux: Changes the window icon (resets on app restart).';
      default:
        return '';
    }
  }
}
