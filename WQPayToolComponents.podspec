#
#  Be sure to run `pod spec lint WQBasicComponents.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  These will help people to find your library, and whilst it
  #  can feel like a chore to fill in it's definitely to your advantage. The
  #  summary should be tweet-length, and the description more in depth.
  #

  s.name         = "WQPayToolComponents"
  s.version      = "0.0.1"
  s.summary      = "支付组件"

  s.description  = <<-DESC
                      将之前的组件进行细致拆分
                      DESC
              

  s.homepage     = "https://github.com/wang68543/WQPayToolComponents"


  s.license      = 'MIT'


  s.author             = { "王强" => "wang68543@163.com" }
 

  s.source       = { :git => "https://github.com/wang68543/WQPayToolComponents.git", :tag => "#{s.version}" }


  s.platform     = :ios, "8.0"

  s.requires_arc = true

  s.prefix_header_contents = '#import <UIKit/UIKit.h>', '#import <Foundation/Foundation.h>'


   s.subspec 'WQPaySDK' do |ss|
       ss.subspec 'WeiXinSdk' do |sss|
       sss.vendored_libraries = "WQPayToolComponents/WQPaySDK/WeiXinSdk/libWeChatSDK.a"
       sss.source_files = "WQPayToolComponents/WQPaySDK/WeiXinSdk/*.h"
       sss.libraries = "sqlite3"
       end

        ss.subspec 'AliPaySDK' do |sss|
           #因为不知道怎么解决相对路径的问题 所以这里写成绝对路径
        openssl_header_paths ='/Users/ggg/Desktop/Components/WQPayDemo/WQPayToolComponents/WQPaySDK/AliPaySDK' 
        # openssl_header_paths = "$(SRCROOT)/WQBasicComponents/PaySDK/AliPaySDK"
        # ss.user_target_xcconfig =  { 'HEADER_SEARCH_PATHS' => openssl_header_paths}
       # ss.pod_target_xcconfig = { 'HEADER_SEARCH_PATHS' => '${}WQBasicComponents/PaySDK/AliPaySDK' }
        #只有这个在pod对象里面才起作用 
        sss.pod_target_xcconfig = { 'HEADER_SEARCH_PATHS' => openssl_header_paths } 
            openssl_files = "WQPayToolComponents/WQPaySDK/AliPaySDK/openssl/*.h"
            sss.subspec 'openssl' do |ssss|
            ssss.source_files = openssl_files
            end

        sss.vendored_frameworks = 'WQPayToolComponents/WQPaySDK/AliPaySDK/AlipaySDK.framework'
        sss.vendored_libraries = "WQPayToolComponents/WQPaySDK/AliPaySDK/libcrypto.a","WQPayToolComponents/WQPaySDK/AliPaySDK/libssl.a"
        sss.resource = 'WQPayToolComponents/AliPaySDK/WQPaySDK/AlipaySDK.bundle'
        sss.frameworks = 'SystemConfiguration','CoreTelephony','QuartzCore','CoreText','CoreGraphics','CFNetwork','CoreMotion'
        sss.libraries = "c++", "z"
        sss.source_files = 'WQPayToolComponents/WQPaySDK/AliPaySDK/*.{h,m}','WQPayToolComponents/WQPaySDK/AliPaySDK/Util/*.{h,m}'
   end

 end
 s.subspec 'WQPayTool' do |ss|
  ss.dependency 'WQPayToolComponents/WQPaySDK'
  ss.source_files = 'WQPayToolComponents/WQPayTool/*.{h,m}'
 end

end
