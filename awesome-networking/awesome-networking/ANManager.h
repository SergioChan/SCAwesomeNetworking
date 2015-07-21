//
//  ANManager.h
//  awesome-networking
//
//  Created by chen Yuheng on 15/7/21.
//  Copyright (c) 2015年 chen Yuheng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ANHeader.h"
#import "ANRequest.h"
#import "AFHTTPRequestOperationManager.h"
#import "AFNetworkActivityIndicatorManager.h"

typedef void (^successBlock)(void);
typedef void (^failErrorBlock)(NSError *error);

@interface ANManager : AFHTTPRequestOperationManager

@end
