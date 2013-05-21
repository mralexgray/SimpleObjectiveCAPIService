//
//  SimpleAPIService.m
//  meatup
//
//  Created by Gareth Shapiro on 14/05/2013.
//  Copyright (c) 2013 Gareth Shapiro. All rights reserved.
//

#import "SimpleObjectiveCAPIService"

@interface SimpleObjectiveCAPIService()

    @property BOOL isLive;
    @property (nonatomic , strong )  NSURL *localURL;

    -(void)loadLive;
    -(void)loadLocal;
    -(NSString *)createLocalURLString;

@end

@implementation SimpleAPIService

-(id)init{
    
    self = [super init];
    
    if (self) {
        
        self.isLive = NO;       // change to YES when the web API is to be used instead of the local files.
       
        // don't use setters 
        _methodName = @"";      // never nil
        _requestType = @"";
    }
    
    return self;
    
}


-(void)setMethodName:(NSString *)methodName{
    
    _methodName = methodName;
    
    self.localURL = [
                      
      [NSBundle mainBundle]
      URLForResource: [self createLocalURLString]
      withExtension: @"json"
                      
   ];
    
}

-(void)setRequestType:(NSString *)requestType{
    
    _requestType = requestType;
    
    self.localURL = [
                     
         [NSBundle mainBundle]
         URLForResource: [self createLocalURLString]
         withExtension: @"json"
                     
    ];
    
}

-(NSString *)createLocalURLString{
    
    NSString *s = @"";
    
    if( _methodName.length > 0 && _requestType.length > 0){
        
        s = [[_methodName stringByReplacingOccurrencesOfString:@"/" withString:@"."] stringByAppendingString: [@"." stringByAppendingString: _requestType]];
        
    }
    
    return [s stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
}


-(void)load{
    
    self.recievedData = nil;
    
    if( self.isLive == YES ){
        
        [self loadLive];

        
    } else {
        
        [self loadLocal];
    }
    
}

-(void)loadLive{
    
    if(
        
        self.methodName.length > 0 &&
        self.parameters != nil &&
        self.requestType.length > 0
       
        ){
        
        NSMutableArray * apiURLComponents = [[NSMutableArray alloc] init];
        [apiURLComponents addObject:API_LIVE_PROTOCOL];
        [apiURLComponents addObject:API_LIVE_HOST];
        [apiURLComponents addObject:API_LIVE_ENDPOINT];
        [apiURLComponents addObject:self.methodName]; 

        NSMutableURLRequest *apiURLRequest = [
                                                 
            [NSMutableURLRequest alloc] initWithURL:
                [[NSURL alloc] initWithString: [apiURLComponents componentsJoinedByString:@""] ]
                                                 
        ];

        apiURLRequest.HTTPMethod = self.requestType;
        apiURLRequest.allHTTPHeaderFields = self.parameters;

        NSOperationQueue *apiQueue = [NSOperationQueue mainQueue];
        
        __block SimpleAPIService *safeSelf = self;
        
        [NSURLConnection sendAsynchronousRequest:apiURLRequest
                                           queue:apiQueue
                               completionHandler:^(NSURLResponse *apiResponse , NSData *apiData , NSError *apiError   ){
                                   
               if( apiData != nil ){
                   
                   safeSelf.recievedData = apiData;
                   
                    [[NSNotificationCenter defaultCenter] postNotificationName:SIMPLE_API_SERVICE_DATA_RECIEVED object:self];
                   
               } else if( apiError ){
                   
                   AppLog(@"SimpleAPIService.loadLive has resulted in an error %@" , apiError);
                   
               }
           
           
        }];

    } else {
        
        AppLog(@"You have called [SimpleAPIService load] and SimpleAPIService.methodName, SimpleAPIService.requestType or SimpleAPIService.parameters has not been set.");
        
    }
    
}

-(void)loadLocal{
    
    if( self.methodName.length > 0 && self.requestType.length > 0){

        self.recievedData = [[NSData alloc] initWithContentsOfURL:self.localURL];
        
        if( self.recievedData != nil ){
            
            [[NSNotificationCenter defaultCenter] postNotificationName:SIMPLE_API_SERVICE_DATA_RECIEVED object:self];
            
        } else {
            
             AppLog(@"loadLocal has resulted in nil data recieved.  Confirm that you have a JSON file matching the methodName and requestType. Eg : methodName.requestType.json - If your methodName has slashes then replace these with periods in the stub file ony.  Eg : user/profile GET endpoint becomes user.profile.GET.json");
        }
        


    } else {
        
        AppLog(@"You need to specifiy SimpleAPIService.methodName and SimpleAPIService.requestType before calling [SimpleAPIService load]");
        
    }
    
}

-(void) prepareToRemove{
    
    self.localURL = nil;
    self.methodName = nil;
    self.requestType = nil;
    self.parameters = nil;
    self.recievedData = nil;
 
}

@end
