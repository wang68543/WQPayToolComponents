# WQPayToolComponents
功能组件
### 本地支持CocoaPods'
    pod 'WQPayToolComponents',~>'0.0.1'
---
万分感谢[Laurent Etiemble](https://github.com/letiemble/OpenSSL-LET)解决支付宝cocoapods集成问题和[nickcheng](https://github.com/nickcheng/libWeChatSDK/blob/master/libWeChatSDK.podspec)解决微信cocoapods集成问题
##### 提示:
>pods 集成的时候如果出现冲突如下冲突:</br>
<font color=red size=3 face="黑体">[!] The 'Pods-[工程名]' target has libraries with conflicting names: libwechatsdk.a. </font>
</br>需要在主工程中删除冲突资源libwechatsdk.a(不删除头文件),然后`pod install`就可成功了.
</br> 其次将刚刚集成过去的资源库(libwechatsdk.a)添加到之前依赖此资源的第三方库中


<font color=red size=3 face="黑体">The 'Pods-XXX' target has transitive dependencies that include static binaries</font>

####在最后面添加如下内容：
```ruby 
pre_install do |installer|
    # workaround for https://github.com/CocoaPods/CocoaPods/issues/3289
    def installer.verify_no_static_framework_transitive_dependencies; 
    end
```