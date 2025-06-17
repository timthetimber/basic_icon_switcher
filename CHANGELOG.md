## 2.0.0

### Breaking Changes
- Modernized API with better error handling and type safety
- Deprecated old methods (`changeIcon`, `resetIcon`, `setDefaultComponent`)

### New Features
- **Modern API**: New `setIcon`, `getCurrentIcon`, `getAvailableIcons`, and `resetToDefaultIcon` methods
- **Type Safety**: Introduction of `IconConfiguration` and `AppIcon` classes
- **Better Error Handling**: Specific exception types (`IconNotSupportedException`, `PlatformNotSupportedException`, `IconSwitchFailedException`)
- **Caching**: Automatic caching of current icon state for better performance
- **Debug Mode**: Optional debug logging for troubleshooting
- **Platform Check**: `isSupported` getter to check platform compatibility
- **Dart 3 Features**: Utilizes modern Dart language features including pattern matching

### Improvements
- Enhanced documentation with modern API examples
- Comprehensive test coverage for all new features
- Better code organization with separate files for exceptions and configurations
- Backward compatibility maintained for existing code

### Technical
- Requires Dart 3.0.5+ (already supported)
- All legacy methods are deprecated but functional
- Cache timeout of 30 seconds for optimal performance

## 1.1.1

- Little fix in Git Repo

## 1.1.0

- Added reset functionality

## 1.0.0

- First automated release

## 0.0.1

- First release
