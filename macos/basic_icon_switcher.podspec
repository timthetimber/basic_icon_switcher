Pod::Spec.new do |s|
  s.name             = 'basic_icon_switcher'
  s.version          = '1.0.0'
  s.summary          = 'A Flutter plugin for dynamically switching the app icon at runtime.'
  s.description      = <<-DESC
A Flutter plugin for switching the dock icon dynamically from Dart code on macOS.
                       DESC
  s.homepage         = 'https://github.com/timthetimber/basic_icon_switcher'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Tim H' => 'tim@hoenlinger.dev' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'FlutterMacOS'

  s.platform = :osx, '10.14'
  s.osx.deployment_target = '10.14'
  s.swift_version = '5.0'
end
