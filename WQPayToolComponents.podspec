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

  s.prefix_header_contents = '#import <UIKit/UIKit.h>','#import <Foundation/Foundation.h>'


  s.subspec 'WQPaySDK' do |ss|
  			#当前路径
  			$dir = File.dirname(__FILE__)
			ss.subspec 'WeiXinSdk' do |sss|

 			   weixin = 'WQPayToolComponents/WQPaySDK/WeiXinSdk/'
  			   sss.requires_arc = false
			   sss.vendored_libraries = weixin + "libWeChatSDK.a"
			   sss.preserve_paths = weixin + "libWeChatSDK.a"
			   sss.source_files = weixin +"*.h"
			   sss.public_header_files = weixin + "*.h"
			   sss.libraries = 'z', 'sqlite3.0', 'c++'
			   sss.frameworks = 'SystemConfiguration', 'CoreTelephony', 'CFNetwork'
			      # 'LIBRARY_SEARCH_PATHS' => '"'+ $dir + '/WQPayToolComponents/WQPaySDK/WeiXinSdk/libWeChatSDK"',
			   # sss.xcconfig = {
					 #    'HEADER_SEARCH_PATHS' => '"'+ $dir + '/WQPayToolComponents/WQPaySDK/WeiXinSdk/libWeChatSDK"'
						# }
			   sss.xcconfig = {
					    'LIBRARY_SEARCH_PATHS' => '"$(PODS_ROOT)/' + weixin + 'libWeChatSDK"',
					    'HEADER_SEARCH_PATHS' => '"$(PODS_ROOT)/' + weixin + 'libWeChatSDK"'
						}

      	 end
   #    	 alipay = 'WQPayToolComponents/WQPaySDK/AliPaySDK/'

   #    	 	ss.subspec 'openssl' do |sss|

		 #      # sss.frameworks = 'SystemConfiguration'

		 #      sss.source_files = alipay +'openssl/**/*.h'

		 #      sss.public_header_files = alipay + "openssl/**/*.h"
		 #      sss.vendored_libraries = alipay +"libcrypto.a",alipay+"libssl.a"
		 #      sss.preserve_paths = alipay +"libcrypto.a",alipay +"libssl.a"
		 #      sss.libraries = 'crypto', 'ssl'
	  # 	 		sss.xcconfig = {
			# 		    'HEADER_SEARCH_PATHS' => '"'+ $dir +'/'+alipay +'/openssl"'
			# 			}
   #    	 		end
		 #    ss.subspec 'AliPaySDK' do |sss|

		 #    	sss.dependency 'WQPayToolComponents/WQPaySDK/openssl'


		 #      sss.vendored_frameworks = alipay +'AlipaySDK.framework'
		 #      sss.resource = alipay + 'AlipaySDK.bundle'
		 #      sss.frameworks = 'SystemConfiguration','CoreTelephony','QuartzCore',
		 #      					'CoreText','CoreGraphics','CFNetwork','CoreMotion'
		 #      sss.libraries = "c++", "z"
		 #      sss.source_files =  alipay +'*.{h,m}',alipay +'Util/*.{h,m}'



		 #    #   sss.xcconfig = {
			# 		 #    'HEADER_SEARCH_PATHS' => '"$(PODS_ROOT)/' + alipay + 'openssl"'
			# 			# }
		 # end
		 #确定打包环境
			# echo "\033[36;1m支付宝签名方式(输入序号,按回车即可) \033[0m"
			# echo "\033[33;1m1. 服务器签名       \033[0m"
			# echo "\033[33;1m2. app签名(需要解决传递依赖问题)     \033[0m"
			# read inputNumber
			# # sleep 0.5
			# environment="$inputNumber"
	      ss.subspec 'WQPaySign' do |sss| 
		      sss.dependency 'OpenSSL' 
		      sss.pod_target_xcconfig = {
		      		'ENABLE_BITCODE' => 'YES'
		      	} 
		      sss.source_files = 'WQPayToolComponents/WQOrderSign/**/*.{h,m}'
		  end
			ss.subspec 'AliPaySDK' do |sss|
 			alipay = 'WQPayToolComponents/WQPaySDK/AliPaySDK/'
 			sss.dependency 'WQPayToolComponents/WQPaySDK/WQPaySign'
		      sss.vendored_frameworks = alipay +'AlipaySDK.framework'
		      sss.resource = alipay + 'AlipaySDK.bundle' 
		      sss.frameworks = 'SystemConfiguration','CoreTelephony','QuartzCore',
		      					'CoreText','CoreGraphics','CFNetwork','CoreMotion'
		      sss.libraries = "c++", "z" 
		      sss.source_files = alipay +'*.{h,m}'
		  end

		 #    ss.subspec 'AliPaySDK' do |sss|
		 #      alipay = 'WQPayToolComponents/WQPaySDK/AliPaySDK/'

		 #      sss.vendored_frameworks = alipay +'AlipaySDK.framework'
		 #      sss.resource = alipay + 'AlipaySDK.bundle'
		 #      sss.frameworks = 'SystemConfiguration','CoreTelephony','QuartzCore',
		 #      					'CoreText','CoreGraphics','CFNetwork','CoreMotion'
		 #      sss.libraries = "c++", "z",'crypto', 'ssl'
		 #      sss.source_files = alipay +'openssl/**/*.h',alipay +'*.{h,m}',alipay +'Util/*.{h,m}'
		 #      #保护目录结构不变，如果不设置，所有头文件都将被放到同一个目录下
		 #      # sss.header_mappings_dir = $dir + '/' + alipay + 'openssl'
	 	# 	  sss.header_dir          = 'openssl'
		 #      sss.public_header_files = alipay + "openssl/**/*.h"
		 #      sss.vendored_libraries = alipay +"libcrypto.a",alipay+"libssl.a"
		 #      sss.preserve_paths = alipay +"libcrypto.a",alipay +"libssl.a"
		 #      sss.xcconfig = {
			# 		    # 'HEADER_SEARCH_PATHS' => '"'+ $dir + '/WQPayToolComponents/WQPaySDK/AliPaySDK/openssl'+'"',
			# 		    'USER_HEADER_SEARCH_PATHS' => '"'+ $dir + '/WQPayToolComponents/WQPaySDK/AliPaySDK/openssl'+'"'
			# 			}

		 #    #   sss.xcconfig = {
			# 		 #    'HEADER_SEARCH_PATHS' => '"$(PODS_ROOT)/' + alipay + 'openssl"'
			# 			# }
		 # end
  end
 s.subspec 'WQPayTool' do |ss|
  ss.dependency 'WQPayToolComponents/WQPaySDK/WeiXinSdk'
  ss.dependency 'WQPayToolComponents/WQPaySDK/AliPaySDK'
  ss.source_files = 'WQPayToolComponents/WQPayTool/*.{h,m}'
 end

end
