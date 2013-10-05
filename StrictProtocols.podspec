Pod::Spec.new do |s|
  s.name         = "StrictProtocols"
  s.version      = "1.0.0"
  s.summary      = "Check ACTUAL existence of an object's implementation of its 'declared' <Protocol> inheritance, not just what it claims to be."
  s.homepage     = "https://github.com/mralexgray/StrictProtocols"
  s.license      = 'zlib'
  s.author       = "Alex Gray"
  s.source       = {
    :git => "https://github.com/mralexgray/BaseModel.git",
    :tag => s.version.to_s
  }
  s.requires_arc = true;
  s.ios.deployment_target = '4.3'
  s.osx.deployment_target = '10.6'
  s.source_files = 'StrictProtocols'
end
