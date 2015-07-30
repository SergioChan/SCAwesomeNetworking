//
//  ANHeader.h
//  awesome-networking
//
//  Created by chen Yuheng on 15/7/21.
//  Copyright (c) 2015年 chen Yuheng. All rights reserved.
//

#ifndef awesome_networking_ANHeader_h
#define awesome_networking_ANHeader_h

#define RequestsKey @"Requests"

typedef NS_ENUM(NSInteger,ANCategory){
    DEFAULT_CATEGORY = 0,
    TEST_CATEGORY,
};

#define MAXCategory 1

#define HTTP_TIMEOUT_CODE -1009
#define HTTP_NONETWORK_CODE -1001
#define HTTP_NOTCONNECTEDTOSERVER_CODE -1004

#define HTTP_RESPONSENOTJSON_CODE 3840

#define GLOBAL_TIMEOUT_INTERVAL 10.0f
#endif
