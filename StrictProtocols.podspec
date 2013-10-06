Pod::Spec.new do |s|
  s.name         = "StrictProtocols"
  s.version      = "1.0.0"
  s.summary      = "Check ACTUAL existence of an object's implementation of its 'declared' <Protocol> inheritance, not just what it claims to be."
  s.homepage     = "https://github.com/mralexgray/StrictProtocols"
  s.license      = { :type => 'zlib', :file => 'LICENCE.md' }
  s.author       = "Alex Gray"
  s.source_files = "NSObject+StrictProtocols"
  s.source       = { :git => "https://github.com/mralexgray/StrictProtocols.git", :tag => s.version.to_s }
  s.requires_arc = true;
  s.ios.deployment_target = "4.3"
  s.osx.deployment_target = "10.6"
end


# A list of file patterns which select the source files that should be added to the Pods project. If the pattern is a directory then the path will automatically have '*.{h,m,mm,c,cpp}' appended.

# Be sure to run `pod spec lint Example.podspec.podspec' to ensure this is a valid spec.
# For details see: https://github.com/CocoaPods/CocoaPods/wiki/The-podspec-format


# A list of resources included with the Pod. These are copied into the target bundle with a build phase script.
# s.resource  = "icon.png"
# s.resources = "Resources/*.png"

# A list of paths to preserve after installing the Pod.
# CocoaPods cleans by default any file that is not used.
# Please don't include documentation, example, and test files.
# s.preserve_paths = "FilesToSave", "MoreFilesToSave"

# Specify a list of frameworks that the application needs to link
# against for this Pod to work.
# s.framework  = 'SomeFramework'
# s.frameworks = 'SomeFramework', 'AnotherFramework'

# Specify a list of libraries that the application needs to link
# against for this Pod to work.
# s.library   = 'iconv'
# s.libraries = 'iconv', 'xml2'

# If this Pod uses ARC, specify it like so.
# s.requires_arc = true

# If you need to specify any other build settings, add them to the
# xcconfig hash.
# s.xcconfig = { 'HEADER_SEARCH_PATHS' => '$(SDKROOT)/usr/include/libxml2' }

# Finally, specify any Pods that this Pod depends on.
# s.dependency 'JSONKit', '~> 1.4'
