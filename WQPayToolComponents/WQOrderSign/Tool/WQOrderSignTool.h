//
//  WQOrderSignTool.h
//  WQPayDemo
//
//  Created by hejinyin on 2017/11/8.
//  Copyright © 2017年 WQMapKit. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface WQOrderSignTool : NSObject
+(NSString *)zfb_OrderSign:(NSString *)orderInfo withRSA2:(BOOL)rsa2;
+(void)wx_payOrderName:(NSString *)orderName withNum:(NSString *)orderNum notifyURL:(NSString *)url price:(NSString *)price compeletion:(void(^)(NSError *error,NSDictionary *results))compeletion;
@end
