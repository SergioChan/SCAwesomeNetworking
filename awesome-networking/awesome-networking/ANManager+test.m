//
//  ANManager+test.m
//  awesome-networking
//
//  Created by chen Yuheng on 15/7/25.
//  Copyright (c) 2015年 chen Yuheng. All rights reserved.
//

#import "ANManager+test.h"

@implementation ANManager(test)

- (void)testRequestCompletion:(completionBlock)completed
                      success:(successWithObjectBlock)success
                      failure:(failErrorBlock)failure
{
    NSString *test_url = @"http://127.0.0.1:8889/test/";
    [self POST:test_url category:TEST_CATEGORY context:[NSDictionary dictionary] tag:1002 parameters:nil completion:^(ANOperation *operation) {
        completed();
    } success:^(ANOperation *operation, id responseObject) {
        success(responseObject);
    } failure:^(ANOperation *operation, NSError *error) {
        failure(error);
    }];
}
@end
