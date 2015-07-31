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
    NSString *test_url = @"http://****.tataufo.com/test/";
    
    Request *t_request = [[Request alloc]init];
    t_request.cmdid = (int32_t)1;
    t_request.timestamp = (int64_t)[[NSDate date] timeIntervalSince1970];
    
    testMessage *t_testMessage = [[testMessage alloc]init];
    t_testMessage.content = @"Hello world!";
    t_testMessage.common = t_request;
    
    testMessageWithImage *t_testMessageWithImage = [[testMessageWithImage alloc]init];
    t_testMessageWithImage.common = t_request;
    t_testMessageWithImage.content = @"Hello world!";
//    t_testMessageWithImage.imagesArray为一个ANFile对象的数组,ANFile由如下代码初始化
    
//    UIImage *image = [UIImage imageNamed:@"test"];
//    ANFile *file = [[ANFile alloc]init];
//    file.content = UIImageJPEGRepresentation(image, 0.3);
//    file.mimetype = @"image/jpeg";
//    file.filename = @"image.jpeg";
    
    [self POST:test_url category:TEST_CATEGORY context:[NSDictionary dictionary] tag:1002 parameters:nil completion:^(ANOperation *operation) {
        completed();
    } success:^(ANOperation *operation, id responseObject) {
        success(responseObject);
    } failure:^(ANOperation *operation, NSError *error) {
        failure(error);
    }];
}
@end
