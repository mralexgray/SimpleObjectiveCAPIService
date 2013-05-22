//
//  SimpleObjectiveCAPIService.m
//
//  Created by Gareth Shapiro on 14/05/2013.
//
//  See : http://www.garethshapiro.com/item/simple-objective-c-api-service
//
//  For more information
//
//  To provide local versions of live API endpoints use the following convention
//
//  REQUEST_TYPE.methodName.json
//
//  A POST call to http://apihost/userlist
//
//  becomes
//
//  POST.userlist.json
//
//  If the method name has a slash then substitute this for a period.
//
//  REQUEST_TYPE.method/name.json
//
//  A POST call to http://apihost/user/list
//
//  becomes
//
//  POST.user.list.json
//
//  Create files describing mock JSON responses with these names and add them to the target.

#import "SimpleObjectiveCAPIService.h"

@interface SimpleObjectiveCAPIService()

    -(void)loadLive;
    -(void)loadLocal;
    -(void)createLocalURLString;

    @property (nonatomic , strong )  NSString *localURLString;

@end

@implementation SimpleObjectiveCAPIService

-(id)init{
    
    self = [super init];
    
    if (self) {
        
        self.isLive = YES;       // change to YES when the web API is to be used instead of the local files.
       
        // don't use setters 
        _methodName = @"";      
        _requestType = @"";
        
        self.localURLString = @"";
        
        self.lastStatusCode = 0; // test for 0 to see if there has been a request made with this SimpleObjectiveCAPIService
        self.lastMethodName = @"";
        self.lastRequestType = @"";
        self.lastLocalURLString = @"";
    }
    
    return self;
    
}

/*
 
    Accessing code provides an endpoint name which is used in the second part of the local file name.

    For eg :

    requestType.eventList.json
 
    Often the endpoint name can have a / for eg :
 
    user/profile
 
    this is converted to :
 
    user.profile
 
    as slashes prove problematic in files names.

 */
-(void)setMethodName:(NSString *)methodName{
    
    _methodName = methodName;

    [self createLocalURLString];
    
}

/*
 
     Accessing code supplies one of :
     
     @"POST"
     @"GET"
     @"PUT"
     @"DELETE"
     
     which is used in the first part of the local file name.  For eg :
     
     POST.methodName.json
 
 */
-(void)setRequestType:(NSString *)requestType{
    
    _requestType = requestType;
    
    [self createLocalURLString];
    
}

/*
 
    A method only used by setMethodName: and setRequestType: to build the local file name.
 
 */
-(void)createLocalURLString{
    
    if( _requestType.length > 0 && _methodName.length > 0){
        
        self.localURLString =  [[_requestType stringByAppendingString:
                                        [@"." stringByAppendingString:
                    [_methodName stringByReplacingOccurrencesOfString:@"/" withString:@"."] ]]
                         stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
        
    }
    
}

/*
 
    A common accessor to retrieve API data regardless of whether the SimpleObjectiveCAPIService is retrieving JSON from a live source or from a local file.
 
 */
-(void)load{
    
    self.recievedData = nil;
    self.lastError = nil;
    self.lastLocalURLString = [[self.localURLString stringByAppendingString:@"."] stringByAppendingString:API_RESPONSE_TYPE];
    
    self.lastMethodName = self.methodName;
    self.lastRequestType = self.requestType;
    self.lastParameters = self.parameters;
    self.lastStatusCode = 0;
    
    if( self.isLive == YES ){
        
        [self loadLive];

        
    } else {
        
        [self loadLocal];
    }
    
}

/*
 
    A method only called by the load method of this class when JSON is being retrieved from a live source.
 
 */
-(void)loadLive{
    
    if(
        
        self.methodName.length > 0 &&
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
        [apiURLRequest setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
        NSOperationQueue *apiQueue = [NSOperationQueue mainQueue];

        [NSURLConnection sendAsynchronousRequest:apiURLRequest
                                           queue:apiQueue
                               completionHandler:^(NSURLResponse *apiResponse , NSData *apiData , NSError *apiError   ){
                                   
                                   
               NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)apiResponse;
              
               self.lastStatusCode = [httpResponse statusCode];
                    
               self.methodName = @"";
               self.requestType = @"";
               self.localURLString = @"";
               self.parameters = nil;
          
               if( [httpResponse statusCode] == 200 ){
                   
                   if( apiData != nil ){
                       
                       self.recievedData = apiData;
                       
                   } else {
                       
                      self.lastError = apiError;
                   }
                   
                   
                   [[NSNotificationCenter defaultCenter] postNotificationName:SIMPLE_API_SERVICE_DATA_RECEIVED object:self];
                   
               } else {

                   [[NSNotificationCenter defaultCenter] postNotificationName:SIMPLE_API_SERVICE_HTTP_ERROR object:self ];
                   
               }
                                   

        }];

    } else {
        
        [NSException raise:@"Problem loading network resource." format:@"You need to specifiy SimpleObjectiveCAPIService methodName and SimpleObjectiveCAPIService requestType before calling SimpleObjectiveCAPIService load."];
        
    }
    
}

/*
 
    A method only called by the load method of this class when JSON is being retrieved from a local source.
 
 */
-(void)loadLocal{
    
    if( self.localURLString.length > 0){

        NSURL *localURL = [[NSBundle mainBundle] URLForResource: self.localURLString withExtension: API_RESPONSE_TYPE];

        if( localURL != nil ){
            
            NSError *error;

            self.recievedData = [[NSData alloc] initWithContentsOfURL: localURL];

            if( self.recievedData != nil ){

                [[NSNotificationCenter defaultCenter] postNotificationName:SIMPLE_API_SERVICE_DATA_RECEIVED object:self];

            } else {

                [NSException raise:@"Problem reading a local resource." format:@"There has been a problem reading a local resource named %@.%@ : %@", self.localURLString , API_RESPONSE_TYPE , error.description];

            }
            
        } else {

             [NSException raise:@"Problem reading a local resource." format: @"A local resources named %@.%@ could not be found.", self.localURLString , API_RESPONSE_TYPE];
        }
        
    } else {
        
        [NSException raise:@"Problem reading a local resource." format:@"You need to specifiy SimpleObjectiveCAPIService methodName and SimpleObjectiveCAPIService requestType before calling SimpleObjectiveCAPIService load."];
        
    }

    self.methodName = @"";
    self.requestType = @"";
    self.localURLString = @"";
    self.parameters = nil;
    
}


/*
 
    Clean Up
 
*/
-(void) prepareToRemove{
    
    self.methodName = nil;
    self.requestType = nil;
    self.parameters = nil;
    self.recievedData = nil;
 
}

@end
