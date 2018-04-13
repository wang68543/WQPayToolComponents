//
//  WQPayTool.m
//  SomeUIKit
//
//  Created by WangQiang on 2017/4/25.
//  Copyright © 2017年 WangQiang. All rights reserved.
//

#import "WQPayTool.h"
#import <UIKit/UIKit.h>
#import "Order.h"
#import "WQOrderSignTool.h"

#ifndef dispatch_main_async_safe
#define dispatch_main_async_safe(block)\
if (strcmp(dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL), dispatch_queue_get_label(dispatch_get_main_queue())) == 0) {\
block();\
} else {\
dispatch_async(dispatch_get_main_queue(), block);\
}
#endif
@interface WQPayTool()<WXApiDelegate>

@property (strong ,nonatomic) WQPayItem *payItem;
@property (copy ,nonatomic) WQPayCompeletion payComepletion;
@property (weak ,nonatomic) id<WQPayToolDelegate> delegate;
@end
@implementation WQPayTool
+(instancetype)manager{
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
-(void)wq_sendPay:(WQPayItem *)payItem compeletion:(WQPayCompeletion)payComepeltion{
    _payItem = payItem;
    _payComepletion = [payComepeltion copy];
   [self setPayItem:payItem];
}
//MARK: 发起支付以代理形式回调
-(void)wq_sendPay:(WQPayItem *)payItem delegate:(id<WQPayToolDelegate>)delegate{
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
    /*
     *生成订单信息及签名
     */
//    将商品信息赋予AlixPayOrder的成员变量
    Order* order = [Order new];
    
    // NOTE: app_id设置
    order.app_id = self.payItem.app_id;
    
    // NOTE: 支付接口名称
    order.method = self.payItem.zfb_method;
    
    // NOTE: 参数编码格式
    order.charset = self.payItem.zfb_charset;
 
    order.notify_url = self.payItem.notify_url;
    
 
    order.timestamp = self.payItem.timeStamp;
    
    // NOTE: 支付版本
    order.version = [[NSBundle mainBundle].infoDictionary objectForKey:@"CFBundleShortVersionString"];
    
    // NOTE: sign_type 根据商户设置的私钥来决定
    //(rsa2PrivateKey.length > 1)?@"RSA2":@"RSA"
    order.sign_type = self.payItem.sign_type;
    
    // NOTE: 商品数据
    order.biz_content = [BizContent new];
    order.biz_content.body = self.payItem.order_description;
    order.biz_content.subject = self.payItem.order_name;
    order.biz_content.out_trade_no = self.payItem.order_num; //订单ID（由商家自行制定）
    order.biz_content.timeout_express = self.payItem.order_timeout; //超时时间设置
    order.biz_content.total_amount = self.payItem.order_price; //商品价格
    
   
    //将商品信息拼接成字符串
 
    NSString *orderInfoEncoded = [order orderInfoEncoded:YES];
    NSString *signedString = self.payItem.order_sign;
    if (signedString.length <= 0) {
        signedString = [WQOrderSignTool zfb_OrderSign:orderInfoEncoded withRSA2:YES];
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
            NSString *message = @"";
            PayResultState state = kPayDefault;
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

- (void)payWithWeiXinSignSelf{
    [WQOrderSignTool wx_payOrderName:self.payItem.description withNum:self.payItem.order_num notifyURL:self.payItem.notify_url price:self.payItem.order_price compeletion:^(NSError *error, NSDictionary *results) {
        PayReq *request = [[PayReq alloc] init];
        request.openID = [results objectForKey:@"appid"];
        request.partnerId = [results objectForKey:@"mch_id"];
        request.prepayId= [results objectForKey:@"prepay_id"];
  
        request.package = [results objectForKey:@"sign_type"];
        request.nonceStr= [results objectForKey:@"nonce_str"];
        request.timeStamp= [[results objectForKey:@"timeStamp"] intValue];
        [WXApi sendReq:request];
    }];
    
}
-(void)payWithWeiXin{
    PayReq* req             = [[PayReq alloc] init];
    req.partnerId           = self.payItem.partner_id;
    req.prepayId            = self.payItem.order_num;
    req.nonceStr            = self.payItem.order_randomStr;
    req.timeStamp           = [self.payItem.timeStamp intValue];
    /*@"Sign=WXPay"*/
    req.package             = self.payItem.sign_type;
    req.sign                = self.payItem.order_sign;
    
    //日志输出
// NSLog(@"appid=%@\npartid=%@\nprepayid=%@\nnoncestr=%@\ntimestamp=%ld\npackage=%@\nsign=%@",req.openID,req.partnerId,req.prepayId,req.nonceStr,(long)req.timeStamp,req.package,req.sign );
    
    [WXApi sendReq:req];
}

-(BOOL)wq_handlePayOpenURL:(NSURL *)url{
    if(!self.delegate || !self.payComepletion){
        return NO;
    }
    if ([url.host isEqualToString:@"safepay"]) {
            // 支付跳转支付宝钱包进行支付，处理支付结果
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:NULL];
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
    dispatch_main_async_safe(^{
        if([self.delegate respondsToSelector:@selector(payToolCompeletion:payState:message:)]){
            [self.delegate payToolCompeletion:self.payItem payState:state message:message];
            self.delegate = nil;
        }else{
            self.payItem?self.payComepletion(state, self.payItem, message):nil;
            self.payItem = nil;
        }
    });
}
@end
