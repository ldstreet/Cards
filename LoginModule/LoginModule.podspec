Pod::Spec.new do |spec|
  spec.name         = 'LoginModule'
  spec.version      = '0.0.1'
  spec.license      = { :type => 'BSD' }
  spec.homepage     = 'https://github.com/ldstreet/Cards'
  spec.authors      = { 'Luke Street' => 'ldstreet@me.com' }
  spec.summary      = 'Building blocks for Cards'
  spec.ios.deployment_target  = '12.1'
  spec.source       = { :git => 'https://github.com/ldstreet/Cards', :tag => '#{spec.version}' }
  spec.source_files = 'Sources/LoginModule/**/*.{swift}'
  spec.framework    = 'UIKit'

  spec.dependency 'LDSiOSKit'

end