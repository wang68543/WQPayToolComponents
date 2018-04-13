//
//  WQPaySignConfig.h
//  WQPayDemo
//
//  Created by hejinyin on 2017/11/11.
//  Copyright © 2017年 WQMapKit. All rights reserved.
//

#ifndef WQPaySignConfig_h
#define WQPaySignConfig_h

//合作身份者id，以2088开头的16位纯数字
#define PartnerID @""
//收款支付宝帐号
//卖家支付宝账号对应的支付宝唯一用户号(以2088开头的16位纯数字)
#define SellerID  @""

////安全校验码（MD5）密钥，以数字和字母组成的32位字符
//#define MD5_KEY @""

//商户私钥，自助生成
#define PartnerPrivKey @""


//支付宝公钥
#define AlipayPubKey   @""


#define zhiFuBaoNotify_url @""//支付宝服务器主动通知商户网站里指定的页面http路径

#define WX_APPID @""
#define WX_PartnerID @""//微信商户ID
#define WX_Scret @"";
#define WX_Key @""


#endif /* WQPaySignConfig_h */
