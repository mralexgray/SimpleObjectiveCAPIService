//
//  SimpleAPIService.h
//  meatup
//
//  Created by Gareth Shapiro on 14/05/2013.
//  Copyright (c) 2013 Gareth Shapiro. All rights reserved.
//

/*

    A wrapper around very simple NSConnection calls to a web service and locading local stub versions of the api responses.

*/
#import <Foundation/Foundation.h>

// NOTIFICATIONS
#define  SIMPLE_API_SERVICE_DATA_RECIEVED @"SimpleAPIService.SIMPLE_API_SERVICE_DATA_RECIEVED"

// API
#define API_LOCAL_PROTOCOL @"file://" // dev version



#define API_LIVE_PROTOCOL @"http://" // for live vesion
#define API_LIVE_HOST @"localhost/" // for live version
#define API_LIVE_ENDPOINT @"meatup/mobile/" // for live version

@interface SimpleAPIService : NSObject

    @property (nonatomic , strong) NSString *methodName;
    @property (nonatomic , strong) NSString *requestType;
    @property (nonatomic , strong) NSDictionary *parameters;
    @property (nonatomic , strong) NSData *recievedData;

    -(id)init;
    -(void)load;

    -(void) prepareToRemove;

@end
