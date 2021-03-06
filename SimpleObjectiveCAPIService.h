//  SimpleObjectiveCAPIService.m
//
//  Created by Gareth Shapiro on 14/05/2013.
//
//  See : http://www.garethshapiro.com/item/simple-objective-c-api-service

/*

    A wrapper around very simple NSConnection calls to a web service or NSData loading local stub JSON versions of the api responses.

*/
#import <Foundation/Foundation.h>

// NOTIFICATIONS
#define SIMPLE_API_SERVICE_DATA_RECEIVED @"SimpleObjectiveCAPIService.SIMPLE_API_SERVICE_DATA_RECEIVED"
#define SIMPLE_API_SERVICE_HTTP_ERROR @"SimpleObjectiveCAPIService.SIMPLE_API_SERVICE_HTTP_ERROR"
// API
#define API_LOCAL_PROTOCOL @"file://" // dev version

#define API_LIVE_PROTOCOL @"http://" // for live vesion
#define API_LIVE_HOST @"localhost/" // for live version
#define API_LIVE_ENDPOINT @"mobile/endpoint/" // for live version

#define API_RESPONSE_TYPE @"json"

@interface SimpleObjectiveCAPIService : NSObject

    @property (readonly) BOOL isLive;

    @property (nonatomic , strong) NSString *methodName;
    @property (nonatomic , strong) NSString *requestType;
    @property (nonatomic , strong) NSDictionary *parameters;
    @property (nonatomic , strong) NSData *recievedData;

    @property (readonly) int lastStatusCode;
    @property (nonatomic , strong, readonly) NSString *lastMethodName;
    @property (nonatomic , strong, readonly) NSString *lastRequestType;
    @property (nonatomic , strong, readonly) NSDictionary *lastParameters;
    @property (nonatomic , strong, readonly) NSString *lastLocalURLString;
    @property (nonatomic , strong, readonly) NSError *lastError;

    -(id)init;
    -(void)load;

    -(void) prepareToRemove;

@end
