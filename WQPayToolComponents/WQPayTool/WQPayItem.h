//
//  WQPayItem.h
//  SomeUIKit
//
//  Created by WangQiang on 2017/4/25.
//  Copyright © 2017年 WangQiang. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSInteger ,PayType){
    kPayZhiFuBao,//支付宝支付
    kPayWeiXin,//微信支付
    kPayWallet,//钱包支付
};
@interface WQPayItem : NSObject

@property (assign ,nonatomic) PayType payType;

/**
 *  订单标题
 */
@property (copy ,nonatomic) NSString *order_name;//订单标题
/**
 *  订单描述
 */
@property (copy ,nonatomic) NSString *order_description;//
/**
 *  价格
 */
@property (copy ,nonatomic) NSString *order_price;//价格
/**
 *  订单编号
 */
@property (copy ,nonatomic) NSString *order_num;
/**
 *  生成订单的签名 (用服务器的签名)
 */
@property (copy ,nonatomic) NSString *order_sign;
/**
 *  时间戳、防重发(用于微信)
 */
@property (copy ,nonatomic) NSString *order_time;
/**
 *  随机字符串 防重发(用于微信)
 */
@property (copy ,nonatomic) NSString *order_randomStr;
/**支付宝服务器端用于异步通知支付成功的url*/
@property (copy ,nonatomic) NSString *notify_url;
@end
