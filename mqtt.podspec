Pod::Spec.new do |s|
  s.name        = "MQTT"
  s.version     = "1.0"
  s.summary     = "MQTT v3.1.1 client library for iOS written with Swift"
  s.homepage    = "https://github.com/VasilyPolyuhovich/mqtt"
  s.license     = { :type => "MIT" }
  s.author       = { "Ankit Agarwal" => "ankit.spd@gmail.com" }
  
  s.requires_arc = true
  s.ios.deployment_target = "9.0"
  s.source   = { :git => "https://github.com/VasilyPolyuhovich/mqtt.git", :tag => "1.0"}
  s.source_files = "Source/{*.h}", "Source/*.swift", "Source/Models/*.swift"
  s.dependency "Starscream", "~> 3.0.2"
end