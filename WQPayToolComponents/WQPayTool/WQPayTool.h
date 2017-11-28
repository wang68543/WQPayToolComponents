//
//  WQPayTool.h
//  SomeUIKit
//
//  Created by WangQiang on 2017/4/25.
//  Copyright © 2017年 WangQiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WQPayItem.h"
#import "WXApi.h"
#import <AlipaySDK/AlipaySDK.h>
static NSString *const kWeiXinAppId = @"";
//
typedef NS_ENUM(NSInteger , PayResultState){
    kPayDefault,
    kPaySuccess, //支付工具支付成功了 
    kPayFailed,
    kPayCanceled,
    kPayAppActiveWait,//app重新激活了 但是支付没有回调过来
};
@protocol WQPayToolDelegate <NSObject>

-(void)payToolCompeletion:(WQPayItem *)item payState:(PayResultState)payState message:(NSString *)message;
@end
typedef void(^WQPayCompeletion)(PayResultState state , WQPayItem *payItem,NSString *errMsg);
@interface WQPayTool : NSObject
+(instancetype)manager;

/** 发起支付 */
-(void)wq_sendPay:(WQPayItem *)payItem delegate:(id<WQPayToolDelegate>)delegate;
-(void)wq_sendPay:(WQPayItem *)payItem compeletion:(WQPayCompeletion)payComepeltion;

/**
  *  用于处理appdelegate里面的回调
  *
  *  @param url               第三方sdk的打开本app的回调的url
  *  @param sourceApplication 回调的源程序
  *  @param annotation        annotation
  *
  *  @return 是否处理  YES代表处理成功，NO代表不处理
  */
//-(BOOL)handleOpenURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation;
-(BOOL)wq_handlePayOpenURL:(NSURL *)url;

@end
