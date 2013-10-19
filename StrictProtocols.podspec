Pod::Spec.new do |s|
  s.name                  = 'StrictProtocols'
  s.version               = '1.0.0'
  s.summary               = 'Tests if objects ACTUALLY implement a <Protocol>\'s @required | @requqired + @optional methods.'
  s.description           = 'The cure to NSObject’s flawed implementation of - (BOOL)conformsToProtocol:(Protocol *)aProtocol; * You can now safely test, cache the results of, and act knowing if the class, or it’s ancestors ACTUALLY implement a protocol’s methods.'
  s.homepage              = 'https://github.com/mralexgray/StrictProtocols'
  s.license               = { :type => "zlib", :file => "LICENSE.StrictProtocols.md" }
  s.author                = { 'Alex Gray' => 'alex@mrgray.com' }
  s.ios.deployment_target = '2.0'
  s.osx.deployment_target = '10.5'
  s.source                = { :git => "https://github.com/mralexgray/StrictProtocols.git", :tag => "1.0.0" }
  s.source_files          = 'NSObject+StrictProtocols.*{h,m}'
  s.framework             = 'Foundation'
  s.library               = 'objc'
  s.requires_arc          = true
  s.xcconfig              = { 'CLANG_LINK_OBJC_RUNTIME' => "YES" }
  end