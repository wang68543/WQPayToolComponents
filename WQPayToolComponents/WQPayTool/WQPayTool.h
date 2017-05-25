//
//  WQPayTool.h
//  SomeUIKit
//
//  Created by WangQiang on 2017/4/25.
//  Copyright © 2017年 WangQiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WQPayItem.h"

static NSString *const kWeiXinAppId = @"wx550a40a0a6922cee";
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
+(instancetype)payManager;
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
-(BOOL)handleOpenURL:(NSURL *)url;
-(void)sendPay:(WQPayItem *)payItem delegate:(id<WQPayToolDelegate>)delegate;
-(void)sendPay:(WQPayItem *)payItem compeletion:(WQPayCompeletion)payComepeltion;
@end
