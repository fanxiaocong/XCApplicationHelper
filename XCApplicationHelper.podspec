Pod::Spec.new do |s|

  s.name         = "XCApplicationHelper"
  s.version      = "0.0.1"
  s.summary      = "处理监听App的生命周期的相关回调"

  s.description  = <<-DESC
XCApplicationHelper，处理监听App的生命周期的相关回调
                   DESC

  s.homepage     = "https://github.com/fanxiaocong/XCApplicationHelper"

  s.license      = "MIT"

  s.author             = { "樊小聪" => "1016697223@qq.com" }

  s.platform     = :ios, "9.0"


  s.source       = { :git => "https://github.com/fanxiaocong/XCApplicationHelper.git", :tag => "#{s.version}" }



  s.source_files  = "XCApplicationHelper/*.{h,m}"

  s.dependency "XCMacros", "~> 1.0.2"

end
