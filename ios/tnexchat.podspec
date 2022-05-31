#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint tnexchat.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'tnexchat'
  s.version          = '0.0.1'
  s.summary          = 'A new flutter plugin project.'
  s.description      = <<-DESC
A new flutter plugin project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '13.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
  s.dependency 'MatrixSDK'
  s.dependency 'KeychainAccess'
  s.dependency 'SDWebImage', '~> 5.0'
  s.dependency 'PureLayout'
  s.dependency 'InputBarAccessoryView'
  s.dependency 'DropDown'
  s.dependency 'ISEmojiView'
  s.dependency 'Alamofire', '~> 5.5'
  s.dependency 'TLPhotoPicker'
  s.dependency 'RxDataSources'
  s.dependency 'SwipeCellKit'
  s.dependency 'FittedSheets', '~> 1.4.6'
  s.dependency 'ImageViewer.swift'
  s.dependency 'ImageViewer.swift/Fetcher'
end
