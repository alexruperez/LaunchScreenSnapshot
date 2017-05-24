Pod::Spec.new do |s|
  s.name             = 'LaunchScreenSnapshot'
  s.version          = '1.0.1'
  s.summary          = 'Protects sensitive data in your app snapshot.'

  s.homepage         = 'https://github.com/alexruperez/LaunchScreenSnapshot'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.authors          = { 'Alex Rupérez' => 'contact@alexruperez.com' }
  s.source           = { :git => 'https://github.com/alexruperez/LaunchScreenSnapshot.git', :tag => s.version.to_s }
  s.social_media_url = "https://twitter.com/alexruperez"
  s.screenshot       = 'https://raw.githubusercontent.com/alexruperez/LaunchScreenSnapshot/master/LaunchScreenSnapshot.png'

  s.ios.deployment_target = '8.0'

  s.source_files     ="LaunchScreenSnapshot/*.{h,swift}"
end