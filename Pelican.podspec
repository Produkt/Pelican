#
# Be sure to run `pod lib lint Zip.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "Pelican"
  s.version          = "0.0.1"
  s.summary          = "Utility class for compressing/decompressing files on iOS and Mac."

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!
  s.description      = <<-DESC
                      Pelican is a simple utility class for compressing/decompressing files on iOS and Mac.
                     DESC

  s.homepage         = "https://github.com/Produkt/Pelican"
  s.license          = { :type => 'GPL', :file => 'LICENSE' }
  s.author           = { 'Daniel Garcia' => 'fillito@gmail.com' }
  s.source           = { :git => 'https://github.com/Produkt/Pelican.git', :tag => "v#{s.version}" }

  s.ios.deployment_target = '8.0'
  s.tvos.deployment_target = '9.0'
  s.watchos.deployment_target = '2.0'
  s.osx.deployment_target = '10.9'
  s.requires_arc = true

  s.source_files = 'src/*.{swift,h}', 'src/minizip/*.{c,h}', 'src/minizip/aes/*.{c,h}'
  s.public_header_files = 'src/*.h'
  s.pod_target_xcconfig = {'SWIFT_INCLUDE_PATHS' => "#{File.dirname(__FILE__)}/src/minizip/** $(SRCROOT)/Pelican/src/minizip/**",'LIBRARY_SEARCH_PATHS' => "#{File.dirname(__FILE__)}/src/ $(SRCROOT)/Pelican/src/"}
  s.libraries = 'z'
  s.preserve_paths  = 'src/minizip/module.modulemap'

  s.dependency 'Result', '~> 3.0.0'
end
