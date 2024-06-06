#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_instance_manager.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_instance_manager'
  s.version          = '0.0.1'
  s.summary          = 'A Flutter instance manager to Dart and native class instances in sync.'
  s.description      = <<-DESC
  A Flutter plugin that provides a instance manager that allows to keep class
  instances in sync between Dart and Objective-C/ Swift.
  Downloaded by pub (not CocoaPods).
                       DESC
  s.homepage         = 'http://github.com/baseflow/flutter_instance_manager'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Baseflow' => 'hello@baseflow.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*.{h,m}'
  s.public_header_files = 'Classes/**/*.h'
  s.module_map = 'Classes/flutter_instance_manager.modulemap'
  s.dependency 'Flutter'
  
  s.platform = :ios, '12.0'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.resource_bundles = {'flutter_instance_manager_privacy' => ['Resources/PrivacyInfo.xcprivacy']}
end
