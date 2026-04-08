Pod::Spec.new do |s|
  s.name             = 'icon_switcher'
  s.version          = '1.0.0'
  s.summary          = 'A Flutter plugin for dynamically switching the app icon at runtime.'
  s.description      = <<-DESC
A Flutter plugin for switching the app icon dynamically from Dart code. Supports iOS and Android.
                       DESC
  s.homepage         = 'https://github.com/timthetimber/icon_switcher'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Tim H' => 'tim@hoenlinger.dev' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'

  s.ios.deployment_target = '12.0'
  s.swift_version = '5.0'
end
