//
//  NSString+NetWork.h
//  DaShang
//
//  Created by WangQiang on 2016/9/30.
//  Copyright © 2016年 Gzmob. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (NetWork)

/**
 获取手机的IP地址

 @param preferIPv4 YES获取ipv4地址 NO 获取IPV6地址
 */
+ (NSString *)getIPAddress:(BOOL)preferIPv4;
@end
