#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint huaji_bluetooth_print.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'huaji_bluetooth_print'
  s.version          = '0.0.1'
  s.summary          = 'A new Flutter project for Gprinter with  bluetooth'
  s.description      = <<-DESC
A new Flutter project for Gprinter with  bluetooth
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.platform = :ios, '8.0'


  # 引入Classes文件夹下所有的*.a库
  s.frameworks = ["SystemConfiguration", "CoreTelephony","WebKit"]
  s.vendored_libraries = '**/*.a'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }
end
