import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_icon_switcher/mobile_icon_switcher.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key}) {
    // Enable debug mode for development
    MobileIconSwitcher.enableDebugMode();
    
    // Legacy method - still works but deprecated
    MobileIconSwitcher.setDefaultComponent("com.example.example.MainActivity");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Icon Switcher Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Mobile Icon Switcher Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> _availableIcons = [];
  String _statusMessage = 'Ready';

  @override
  void initState() {
    super.initState();
    _loadIconInfo();
  }

  Future<void> _loadIconInfo() async {
    if (!MobileIconSwitcher.isSupported) {
      setState(() {
        _statusMessage = 'Icon switching not supported on this platform';
      });
      return;
    }

    try {
      final currentIcon = await MobileIconSwitcher.getCurrentIcon();
      final availableIcons = await MobileIconSwitcher.getAvailableIcons();
      
      setState(() {
        _availableIcons = availableIcons;
        _statusMessage = 'Current icon: ${currentIcon ?? 'Unknown'}';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error loading icon info: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(_statusMessage),
                    const SizedBox(height: 8),
                    Text('Platform supported: ${MobileIconSwitcher.isSupported}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Modern API (Recommended)',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _switchAppIconModern("alternative"),
              child: const Text("Switch to Alternative Icon"),
            ),
            ElevatedButton(
              onPressed: () => _switchAppIconModern("premium"),
              child: const Text("Switch to Premium Icon"),
            ),
            ElevatedButton(
              onPressed: _resetAppIconModern,
              child: const Text("Reset to Default Icon"),
            ),
            const SizedBox(height: 16),
            Text(
              'Legacy API (Deprecated)',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _switchAppIconLegacy("first"),
              child: const Text("Legacy: Switch Icon"),
            ),
            ElevatedButton(
              onPressed: _resetAppIconLegacy,
              child: const Text("Legacy: Reset Icon"),
            ),
            const SizedBox(height: 16),
            if (_availableIcons.isNotEmpty) ...[
              Text(
                'Available Icons: ${_availableIcons.join(', ')}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Modern API methods
  Future<void> _switchAppIconModern(String iconName) async {
    if (!MobileIconSwitcher.isSupported) {
      _updateStatus('Icon switching not supported on this platform');
      return;
    }

    try {
      // Using the modern API with proper error handling
      await MobileIconSwitcher.setIcon(
        iconName: iconName,
        activityAlias: 'com.example.example.${iconName[0].toUpperCase()}${iconName.substring(1).toLowerCase()}',
      );
      
      await _loadIconInfo(); // Refresh status
      _updateStatus('Successfully switched to $iconName icon');
    } on IconNotSupportedException catch (e) {
      _updateStatus('Icon not supported: ${e.message}');
    } on PlatformNotSupportedException catch (e) {
      _updateStatus('Platform not supported: ${e.message}');
    } on IconSwitchFailedException catch (e) {
      _updateStatus('Icon switch failed: ${e.message}');
    } catch (e) {
      _updateStatus('Unexpected error: $e');
    }
  }

  Future<void> _resetAppIconModern() async {
    if (!MobileIconSwitcher.isSupported) {
      _updateStatus('Icon switching not supported on this platform');
      return;
    }

    try {
      await MobileIconSwitcher.resetToDefaultIcon();
      await _loadIconInfo(); // Refresh status
      _updateStatus('Successfully reset to default icon');
    } on PlatformNotSupportedException catch (e) {
      _updateStatus('Platform not supported: ${e.message}');
    } on IconSwitchFailedException catch (e) {
      _updateStatus('Reset failed: ${e.message}');
    } catch (e) {
      _updateStatus('Unexpected error: $e');
    }
  }

  // Legacy API methods (deprecated)
  Future<void> _switchAppIconLegacy(String name) async {
    try {
      final success = await MobileIconSwitcher.changeIcon(
        name,
        'com.example.example.${name[0].toUpperCase()}${name.substring(1).toLowerCase()}'
      );
      _updateStatus(success ? 'Legacy: Icon switched successfully' : 'Legacy: Icon switch failed');
    } on PlatformException catch (e) {
      _updateStatus('Legacy: Error while trying to switch the apps icon: ${e.message}');
    }
  }

  Future<void> _resetAppIconLegacy() async {
    try {
      final success = await MobileIconSwitcher.resetIcon();
      _updateStatus(success ? 'Legacy: Icon reset successfully' : 'Legacy: Icon reset failed');
    } on PlatformException catch (e) {
      _updateStatus('Legacy: Error while trying to reset the apps icon: ${e.message}');
    }
  }

  void _updateStatus(String message) {
    setState(() {
      _statusMessage = message;
    });
    
    // Show snackbar for user feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
