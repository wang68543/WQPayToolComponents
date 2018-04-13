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

/** 商户ID 即收款人ID */
@property (copy    ,nonatomic) NSString *partner_id;
/** 与支付SDK签订的当前app的合作ID */
@property (copy    ,nonatomic) NSString *app_id;
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

/** 签名方式 */
@property (assign  ,nonatomic) NSString *sign_type;
/**
 *  时间戳、防重发(用于微信)
 */
@property (copy ,nonatomic) NSString *timeStamp;

/**
 *  随机字符串 防重发(用于微信)
 */
@property (copy ,nonatomic) NSString *order_randomStr;


/**支付宝服务器端用于异步通知支付成功的url*/
@property (copy ,nonatomic) NSString *notify_url;
/**
     NOTE: 该笔订单允许的最晚付款时间，逾期将关闭交易。(支付宝)
         取值范围：1m～15d m-分钟，h-小时，d-天，1c-当天(1c-当天的情况下，无论交易何时创建，都在0点关闭)
         该参数数值不接受小数点， 如1.5h，可转换为90m。
 */
@property (strong  ,nonatomic) NSString *order_timeout;
/** 销售产品码，商家和支付宝签约的产品码 (如 QUICK_MSECURITY_PAY) */
@property (copy    ,nonatomic) NSString *product_code;

/** 支付宝 支付接口名称 */
@property (copy    ,nonatomic) NSString *zfb_method;
/** 参数编码格式，如utf-8,gbk,gb2312等 */
@property (copy    ,nonatomic) NSString *zfb_charset;

@end
