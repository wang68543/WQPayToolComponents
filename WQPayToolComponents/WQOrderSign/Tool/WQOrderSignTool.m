//
//  WQOrderSignTool.m
//  WQPayDemo
//
//  Created by hejinyin on 2017/11/8.
//  Copyright © 2017年 WQMapKit. All rights reserved.
//

#import "WQOrderSignTool.h"
#import "RSADataSigner.h"
#import "WQPaySignConfig.h"
#import "DataMD5.h"
#import "XMLDictionary.h"
#import "getIPhoneIP.h"

@implementation WQOrderSignTool

+(NSString *)zfb_OrderSign:(NSString *)orderInfo withRSA2:(BOOL)rsa2{
 
    NSString *rsaPrivateKey = PartnerPrivKey;
    
    // NOTE: 获取私钥并将商户信息签名，外部商户的加签过程请务必放在服务端，防止公私钥数据泄露；
    //       需要遵循RSA签名规范，并将签名字符串base64编码和UrlEncode
    RSADataSigner* signer = [[RSADataSigner alloc] initWithPrivateKey:rsaPrivateKey];

    NSString *signedString = [signer signString:orderInfo withRSA2:rsa2];
    
    return signedString;

}
#pragma mark - 微信支付相关方法
+(void)wx_payOrderName:(NSString *)orderName withNum:(NSString *)orderNum notifyURL:(NSString *)url price:(NSString *)price compeletion:(void(^)(NSError *error,NSDictionary *results))compeletion{
    //应用APPID
    NSString *appid = WX_APPID;
    //微信支付商户号
    NSString *mch_id = WX_PartnerID;
    //产生随机字符串，这里最好使用和安卓端一致的生成逻辑
    NSString *nonce_str =[self generateTradeNO];
    NSString *body = orderName;
    //随机产生订单号用于测试，正式使用请换成你从自己服务器获取的订单号
    NSString *out_trade_no = orderNum;
    //交易价格1表示0.01元，10表示0.1元
    NSString *total_fee = [NSString stringWithFormat:@"%.0f",[price floatValue]*100];
    //获取本机IP地址，请再wifi环境下测试，否则获取的ip地址为error，正确格式应该是8.8.8.8
    NSString *spbill_create_ip =[getIPhoneIP getIPAddress];
    //交易结果通知网站此处用于测试，随意填写，正式使用时填写正确网站
    NSString *noti_url = url;
    NSString *trade_type =@"APP";
    //商户密钥
    NSString *partner = WX_Key;
    //获取sign签名
    DataMD5 *data = [[DataMD5 alloc] initWithAppid:appid mch_id:mch_id nonce_str:nonce_str partner_id:partner body:body out_trade_no:out_trade_no total_fee:total_fee spbill_create_ip:spbill_create_ip notify_url:noti_url trade_type:trade_type] ;
    
    NSString *sign = [data getSignForMD5];
    //设置参数并转化成xml格式
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:appid forKey:@"appid"];//公众账号ID
    [dic setValue:mch_id forKey:@"mch_id"];//商户号
    [dic setValue:nonce_str forKey:@"nonce_str"];//随机字符串
    [dic setValue:sign forKey:@"sign"];//签名
    [dic setValue:body forKey:@"body"];//商品描述
    [dic setValue:out_trade_no forKey:@"out_trade_no"];//订单号
    [dic setValue:total_fee forKey:@"total_fee"];//金额
    [dic setValue:spbill_create_ip forKey:@"spbill_create_ip"];//终端IP
    [dic setValue:noti_url forKey:@"notify_url"];//通知地址
    [dic setValue:trade_type forKey:@"trade_type"];//交易类型
    // 转换成xml字符串
    NSString *string = [dic XMLString];
    [self http:string payParams:dic compeletion:compeletion];
}


#pragma mark - 拿到转换好的xml发送请求
+ (void)http:(NSString *)xml payParams:(NSDictionary *)params compeletion:(void(^)(NSError *error,NSDictionary *results))compeletion{
    //    NSString *paramesXmlString  上面的字符串
    //创建URL
    NSURL *unifiedOrderURL = [NSURL URLWithString:@"https://api.mch.weixin.qq.com/pay/unifiedorder"];
    //请求
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:unifiedOrderURL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:5.0];
    [request addValue:@"text/xml" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    
    //paramesXmlString 上面由后台生成的xml JSON字符串;
    NSData *httData = [xml dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:httData];
    NSURLSessionDataTask *task = [[NSURLSession sharedSession]dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] ;
        // LXLog(@"responseString is %@",responseString);
        //将微信返回的xml数据解析转义成字典
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:[NSDictionary dictionaryWithXMLString:responseString]];
        //判断返回的许可
        if ([[dic objectForKey:@"result_code"] isEqualToString:@"SUCCESS"] &&[[dic objectForKey:@"return_code"] isEqualToString:@"SUCCESS"] ) {
            //发起微信支付，设置参数
            
            [dic setValue:[dic objectForKey:@"prepay_id"] forKey:@"trade_no"];
            [dic setValue:@"Sign=WXPay" forKey:@"sign_type"];
 
            //将当前事件转化成时间戳
            NSDate *datenow = [NSDate date];
//            NSDateFormatter* formatter = [NSDateFormatter new];
//            [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
     
            NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[datenow timeIntervalSince1970]];
            UInt32 timeStamp =[timeSp intValue];
            [dic setValue:@(timeStamp) forKey:@"timeStamp"];
            // 签名加密
            DataMD5 *md5 = [[DataMD5 alloc] init];
            //二次签名
            NSString *sign =[md5 createMD5SingForPay:WX_APPID partnerid:WX_PartnerID prepayid:[dic objectForKey:@"prepay_id"] package:[dic objectForKey:@"sign_type"] noncestr:[dic objectForKey:@"nonce_str"] timestamp:timeStamp];
            [dic setValue:sign forKey:@"order_sign"];
            if (compeletion) {
                compeletion(nil,dic);
            }
            
        }else{
            if (compeletion) {
                compeletion([NSError errorWithDomain:@"WQPayTool" code:-2000 userInfo:@{NSLocalizedDescriptionKey:@"微信支付参数错误"}],nil);
            }
 
        }
    }];
    [task resume];
    
    
} 
//MARK: =========== 产生随机订单号 ===========
+ (NSString *)generateTradeNO {
    static int kNumber = 15;
    
    NSString *sourceStr = @"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    NSMutableString *resultStr = [[NSMutableString alloc] init];
    srand(time(0)); // 此行代码有警告:
    for (int i = 0; i < kNumber; i++) {
        unsigned index = rand() % [sourceStr length];
        NSString *oneStr = [sourceStr substringWithRange:NSMakeRange(index, 1)];
        [resultStr appendString:oneStr];
    }
    return resultStr;
}
@end
