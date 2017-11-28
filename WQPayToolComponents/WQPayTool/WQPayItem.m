//
//  WQPayItem.m
//  SomeUIKit
//
//  Created by WangQiang on 2017/4/25.
//  Copyright © 2017年 WangQiang. All rights reserved.
//

#import "WQPayItem.h"

@implementation WQPayItem
-(void)commonInit{
    if (self.payType == kPayZhiFuBao) {
        NSDateFormatter* formatter = [NSDateFormatter new];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        _timeStamp = [formatter stringFromDate:[NSDate date]];
        _order_timeout = @"30m";
        _zfb_method =  @"alipay.trade.app.pay";
        _zfb_charset = @"utf-8";
    }else if(self.payType == kPayWeiXin){
        _timeStamp = [NSString stringWithFormat:@"%.0f",[NSDate date].timeIntervalSince1970];
        _sign_type = @"Sign=WXPay";
    }
}

@end
