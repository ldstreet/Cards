Pod::Spec.new do |spec|
  spec.name         = 'LDSiOSKit'
  spec.version      = '0.0.1'
  spec.license      = { :type => 'BSD' }
  spec.homepage     = 'https://github.com/ldstreet/Cards'
  spec.authors      = { 'Luke Street' => 'ldstreet@me.com' }
  spec.summary      = 'Common iOS code'
  spec.ios.deployment_target  = '12.1'
  spec.source       = { :git => 'https://github.com/ldstreet/Cards', :tag => '#{spec.version}' }
  spec.source_files = 'Sources/LDSiOSKit/**/*.{swift}'
  spec.framework    = 'UIKit'

end
