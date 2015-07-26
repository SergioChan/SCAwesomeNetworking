//
//  ANManager+test.h
//  awesome-networking
//
//  Created by chen Yuheng on 15/7/25.
//  Copyright (c) 2015年 chen Yuheng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ANManager.h"

@interface ANManager(test)

- (void)testRequestCompletion:(completionBlock)completed
                      success:(successWithObjectBlock)success
                      failure:(failErrorBlock)failure;
@end
