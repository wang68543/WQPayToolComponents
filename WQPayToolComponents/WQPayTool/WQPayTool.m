//
//  WQPayTool.m
//  SomeUIKit
//
//  Created by WangQiang on 2017/4/25.
//  Copyright © 2017年 WangQiang. All rights reserved.
//

#import "WQPayTool.h"
#import <UIKit/UIKit.h>
#import "WXApi.h"
#import "Order.h"
#import <AlipaySDK/AlipaySDK.h>
#import "RSADataSigner.h"
@interface WQPayTool()<WXApiDelegate>

@property (strong ,nonatomic) WQPayItem *payItem;
@property (copy ,nonatomic) WQPayCompeletion payComepletion;
@property (weak ,nonatomic) id<WQPayToolDelegate> delegate;
@end
@implementation WQPayTool
+(instancetype)payManager{
    static WQPayTool *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    return self;
}
//MARK: 这个通知会在handOpenURL后面调用当app通过OpenURL被打开的时候
- (void)appDidBecomeActive{
    [self callBackWithState:kPayAppActiveWait message:nil];
}
//MARK: 发起支付以Block形式回调
-(void)sendPay:(WQPayItem *)payItem compeletion:(WQPayCompeletion)payComepeltion{
    _payItem = payItem;
    _payComepletion = [payComepeltion copy];
   [self setPayItem:payItem];
}
//MARK: 发起支付以代理形式回调
-(void)sendPay:(WQPayItem *)payItem delegate:(id<WQPayToolDelegate>)delegate{
    _delegate = delegate;
    _payItem = payItem;
    [self setPayItem:payItem];
}
//MARK: 发起支付
-(void)sendPayWithItem:(WQPayItem *)payItem{
    if(payItem.payType == kPayZhiFuBao){
        [self payWithZhiFuBao];
    }else{
        if(![WXApi isWXAppInstalled]||![WXApi isWXAppSupportApi]){
            [self callBackWithState:kPayFailed message:@"未安装微信客户端"];
        }else{
          [self payWithWeiXin];
        }
        
    }
}

- (void)payWithZhiFuBao{
    //重要说明
    //这里只是为了方便直接向商户展示支付宝的整个支付流程；所以Demo中加签过程直接放在客户端完成；
    //真实App里，privateKey等数据严禁放在客户端，加签过程务必要放在服务端完成；
    //防止商户私密数据泄露，造成不必要的资金损失，及面临各种安全风险；
    /*============================================================================*/
    /*=======================需要填写商户app申请的===================================*/
    /*============================================================================*/
    
    NSString *appID = @"";
    
    // 如下私钥，rsa2PrivateKey 或者 rsaPrivateKey 只需要填入一个
    // 如果商户两个都设置了，优先使用 rsa2PrivateKey
    // rsa2PrivateKey 可以保证商户交易在更加安全的环境下进行，建议使用 rsa2PrivateKey
    // 获取 rsa2PrivateKey，建议使用支付宝提供的公私钥生成工具生成，
    // 工具地址：https://doc.open.alipay.com/docs/doc.htm?treeId=291&articleId=106097&docType=1
    NSString *rsa2PrivateKey = @"";
    NSString *rsaPrivateKey = @"";
    
    /*
     *生成订单信息及签名
     */
//    将商品信息赋予AlixPayOrder的成员变量
    Order* order = [Order new];
    
    // NOTE: app_id设置
    order.app_id = appID;
    
    // NOTE: 支付接口名称
    order.method = @"alipay.trade.app.pay";
    
    // NOTE: 参数编码格式
    order.charset = @"utf-8";
    
    if(self.payItem.notify_url.length > 0){
        order.notify_url = self.payItem.notify_url;
    }
    // NOTE: 当前时间点
    NSDateFormatter* formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    order.timestamp = [formatter stringFromDate:[NSDate date]];
    
    // NOTE: 支付版本
    order.version = @"1.0";
    
    // NOTE: sign_type 根据商户设置的私钥来决定
    order.sign_type = (rsa2PrivateKey.length > 1)?@"RSA2":@"RSA";
    
    // NOTE: 商品数据
    order.biz_content = [BizContent new];
    order.biz_content.body = self.payItem.order_description;
    order.biz_content.subject = self.payItem.order_name;
    order.biz_content.out_trade_no = self.payItem.order_num; //订单ID（由商家自行制定）
    order.biz_content.timeout_express = @"30m"; //超时时间设置
    order.biz_content.total_amount = self.payItem.order_price; //商品价格
    
    //将商品信息拼接成字符串
    NSString *orderInfo = [order orderInfoEncoded:NO];
    NSString *orderInfoEncoded = [order orderInfoEncoded:YES];
    NSLog(@"orderSpec = %@",orderInfo);
    
    // NOTE: 获取私钥并将商户信息签名，外部商户的加签过程请务必放在服务端，防止公私钥数据泄露；
    //       需要遵循RSA签名规范，并将签名字符串base64编码和UrlEncode
    NSString *signedString = nil;
    RSADataSigner* signer = [[RSADataSigner alloc] initWithPrivateKey:((rsa2PrivateKey.length > 1)?rsa2PrivateKey:rsaPrivateKey)];
    if ((rsa2PrivateKey.length > 1)) {
        signedString = [signer signString:orderInfo withRSA2:YES];
    } else {
        signedString = [signer signString:orderInfo withRSA2:NO];
    }
    
    // NOTE: 如果加签成功，则继续执行支付
    if (signedString != nil) {
        //应用注册scheme,在AliSDKDemo-Info.plist定义URL types
        NSString *appScheme = @"alisdkdemo";
        
        // NOTE: 将签名成功字符串格式化为订单字符串,请严格按照该格式
        NSString *orderString = [NSString stringWithFormat:@"%@&sign=%@",
                                 orderInfoEncoded, signedString];
        
        // NOTE: 调用支付结果开始支付
        [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
            NSLog(@"reslut = %@",resultDic);
            NSString *message = @"";
            PayResultState state =kPayDefault;
            switch ([[resultDic objectForKey:@"resultStatus"] intValue]) {
                case 9000:
                    message = NSLocalizedString(@"支付成功", nil);
                    state = kPaySuccess;
                    break;
                case 6001:
                    //用户中途取消
                    message = NSLocalizedString(@"支付取消", nil);
                    state = kPayCanceled;
                    break;
                case 8000://正在处理中
                case 4000://订单支付失败
                case 6002://网络连接出错
                    message = NSLocalizedString(@"支付失败", nil);
                    state = kPayFailed;
                    
                    break;
                default:
                    message = NSLocalizedString(@"支付失败", nil);
                    state = kPayFailed;
                    break;
            }
            [self callBackWithState:state message:message];
        }];
    }
}

-(void)payWithWeiXin{
    PayReq* req             = [[PayReq alloc] init];
    //    req.openID              = @"wxf66ed2035f6dd325";
    req.partnerId           = @"1420072802";
    req.prepayId            = self.payItem.order_num;
    req.nonceStr            = self.payItem.order_randomStr;
    req.timeStamp           = self.payItem.order_time.intValue;
    req.package             = @"Sign=WXPay";
    req.sign                = self.payItem.order_sign;
    
    //日志输出
// NSLog(@"appid=%@\npartid=%@\nprepayid=%@\nnoncestr=%@\ntimestamp=%ld\npackage=%@\nsign=%@",req.openID,req.partnerId,req.prepayId,req.nonceStr,(long)req.timeStamp,req.package,req.sign );
    
    [WXApi sendReq:req];
}

-(BOOL)handleOpenURL:(NSURL *)url{
    //这里处理支付宝跟微信回调
    //微信支付取消url: wx49bbbadfb77cbbbd://pay/?returnKey=(null)&ret=-2
    //微信支付成功url: wx49bbbadfb77cbbbd://pay/?returnKey=&ret=0
    /**
     * url.scheme wx49bbbadfb77cbbbd
     * url.query returnKey=&ret=0
     * url.host pay
     */
    
    /**
     ** [url.absoluteString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] url需要解码*
     *支付宝支付取消: zfb2016072701674288://safepay/?{"memo":{"result":"","memo":"用户中途取消","ResultStatus":"6001"},"requestType":"safepay"}
     
     *  url.host safepay
     */
    if(!self.delegate || !self.payComepletion){
        return NO;
    }
    if ([url.host isEqualToString:@"safepay"]) {
            // 支付跳转支付宝钱包进行支付，处理支付结果
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            NSLog(@"result = %@",resultDic);
        }];
        
        // 授权跳转支付宝钱包进行支付，处理支付结果
//        [[AlipaySDK defaultService] processAuth_V2Result:url standbyCallback:^(NSDictionary *resultDic) {
//            NSLog(@"result = %@",resultDic);
//            // 解析 auth code
//            NSString *result = resultDic[@"result"];
//            NSString *authCode = nil;
//            if (result.length>0) {
//                NSArray *resultArr = [result componentsSeparatedByString:@"&"];
//                for (NSString *subResult in resultArr) {
//                    if (subResult.length > 10 && [subResult hasPrefix:@"auth_code="]) {
//                        authCode = [subResult substringFromIndex:10];
//                        break;
//                    }
//                }
//            }
//            NSLog(@"授权结果 authCode = %@", authCode?:@"");
//        }];
        
        return YES;
    }else if([url.host isEqualToString:@"pay"] && [url.scheme isEqualToString:kWeiXinAppId]){
        BOOL result = [WXApi handleOpenURL:url delegate:self];
        return result;
    }
    return NO;
}
/** 发送一个sendReq后，收到微信的回应 */
- (void)onResp:(BaseResp *)resp{
    if([resp isKindOfClass:[PayResp class]]){
        NSString *message = @"";
        PayResultState state =kPayDefault;
        PayResp*response=(PayResp*)resp;
        switch(response.errCode){
            case WXSuccess:
                //服务器端查询支付通知或查询API返回的结果再提示成功
                state = kPaySuccess;
                break;
            default:
                state = kPayFailed;
                message = @"微信支付失败";
                break;
    }
        [self callBackWithState:state message:message];
 }
}
-(void)callBackWithState:(PayResultState)state message:(NSString *)message{
    if([self.delegate respondsToSelector:@selector(payToolCompeletion:payState:message:)]){
        [self.delegate payToolCompeletion:self.payItem payState:state message:message];
        self.delegate = nil;
    }else{
        self.payItem?self.payComepletion(state, self.payItem, message):nil;
        self.payItem = nil;
    }
}
@end
