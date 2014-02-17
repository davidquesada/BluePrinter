//
//  MPrintRequest.m
//  BluePrinter
//
//  Created by David Paul Quesada on 1/14/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

#import "MPrintRequest.h"
#import "MPrintResponse.h"

@interface MPrintRequest ()<NSURLConnectionDelegate, NSURLConnectionDataDelegate>
{
    BOOL _isMultipartForm;
    NSString *_boundary;
    NSMutableData *_bodyData;
}
@property NSString *endpoint;
@property Method method;

@property BOOL started;
@property NSMutableURLRequest *request;
@property(readonly) NSURL *url;
@property(copy) void (^mycompletion)(MPrintResponse * response);

@property NSMutableData *data;
-(BOOL)createRequest; // Try to create an actual NSURLRequest object. return NO if not able to do so.
-(void)makeMultipartForm;
-(void)appendBoundary;

@property MPrintResponse *response;

@end

@implementation MPrintRequest

+(void)load
{
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
}

+(NSString *)baseURL
{
    return @"https://mprint.umich.edu/api";
}

- (id)init
{
    self = [super init];
    if (self) {
        self.timeout = 10.0;
        self.request = [[NSMutableURLRequest alloc] init];
    }
    return self;
}

-(instancetype)initWithEndpoint:(NSString *)endpoint method:(Method)method
{
    if ((self = [self init]))
    {
        self.endpoint = endpoint;
        self.method = method;
    }
    return self;
}

-(instancetype)initWithEndpoint:(NSString *)endpoint
{
    return self = [self initWithEndpoint:endpoint method:GET];
}

-(instancetype)initWithCustomURL:(NSURL *)url method:(Method)method
{
    if ((self = [self init]))
    {
        self.customURL = url;
        self.method = method;
    }
    return self;
}

-(instancetype)initWithCustomURL:(NSURL *)url
{
    return self = [self initWithCustomURL:url method:GET];
}

-(NSURL *)url
{
    if (self.customURL)
        return self.customURL;
//    NSMUtableu
    NSString *s = [[self.class baseURL] stringByAppendingString:self.endpoint];
    NSLog(@"Building url: %@", s);
    return [NSURL URLWithString:s];
}

-(NSMutableURLRequest *)urlRequest
{
    return [self request];
}

-(BOOL)createRequest
{
    // Don't make another one.
//    if (self.request)
    if (self.started)
        return NO;
    self.started = YES;
    
    self.request.URL = [self url];
    self.request.timeoutInterval = 1.0 + self.timeout;
    self.request.HTTPShouldHandleCookies = YES;
    
    switch (self.method) {
        case POST: [self.request setHTTPMethod:@"POST"]; break;
        case GET: [self.request setHTTPMethod:@"GET"]; break;
        case PUT: [self.request setHTTPMethod:@"PUT"]; break;
        case DELETE: [self.request setHTTPMethod:@"DELETE"]; break;
            
        default: [self.request setHTTPMethod:@"GET"];
    }
    
    if (_isMultipartForm)
        [self.request setHTTPBody:_bodyData];
    
    return YES;
}

-(void)performWithCompletion:(void (^)(MPrintResponse *))completion
{
//    char *write = (char *)(0);
//    *write = 'h';
    
    // NO. It's not here yet.
    if (![self createRequest])
        return;
    // TODO: If we fail here, do we want to call 'completion'?
    
    self.data = [[NSMutableData alloc] init];
    self.response = [[MPrintResponse alloc] init];
    
    self.mycompletion = [completion copy];

    [self.request setValue:@"keep-alive" forHTTPHeaderField:@"Connection"];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:self.request delegate:self startImmediately:NO];
    [connection start];
}

#pragma mark - Multipart Form Stuff

-(void)makeMultipartForm
{
    if (_isMultipartForm)
        return;
    _isMultipartForm = YES;
    
    self.method = POST;
    self.request.HTTPMethod = @"POST";
    _boundary = @"------------QUESOi7P3uVG8347RW8xu5H6aJCvSyAS947";
    
    _bodyData = [[NSMutableData alloc] init];
    [self appendBoundary];
    
    id contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", _boundary];
    [self.request addValue:contentType forHTTPHeaderField:@"Content-Type"];
}

-(void)appendBoundary
{
    [_bodyData appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", _boundary] dataUsingEncoding:NSUTF8StringEncoding]];
}

-(void)addFormValue:(NSString *)value forKey:(NSString *)key
{
    [self makeMultipartForm];
   
    // TODO: Here is probably where I would/should sanitize the data.
    NSData *data = [value dataUsingEncoding:NSUTF8StringEncoding];
    [self addFormData:data forKey:key withFilename:nil contentType:nil];
}

-(void)addFormData:(NSData *)data forKey:(NSString *)key withFilename:(NSString *)filename contentType:(NSString *)contentType
{
    [self makeMultipartForm];
    
    NSMutableString *header = [[NSMutableString alloc] initWithFormat:@"Content-Disposition: form-data; name=\"%@\"", key];
    
    if (filename)
        [header appendFormat:@"; filename=\"%@\"", filename];
    
    if (contentType)
        [header appendFormat:@"\r\nContent-Type: \"%@\"", contentType];
    
    [header appendString:@"\r\n\r\n"];
    
    NSData *headerData = [header dataUsingEncoding:NSUTF8StringEncoding];
    [_bodyData appendData:headerData];
    [_bodyData appendData:data];
    [self appendBoundary];
}

#pragma mark - NSURLConnection Delegate Methods

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"Connection completed!");
    if (!self.mycompletion)
    {
        NSLog(@"But nobody cares");
        //return;
    }
    
    self.response.data = self.data;
    
    NSString *cont = [[NSString alloc] initWithData:self.data encoding:NSUTF8StringEncoding];
    NSLog(@"Contents: %@", cont);
    
    self.response.jsonObject = [NSJSONSerialization JSONObjectWithData:self.data options:kNilOptions error:nil];
    self.response.statusCode = statusCodeForStatusString(self.response.statusString);
    
    if (self.mycompletion)
        self.mycompletion(self.response);
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"Connection failed");
    if (self.mycompletion)
        self.mycompletion(nil);
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse *res = (id)response;
    NSLog(@"Got response. StatusCode(%d)", res.statusCode);
    
    self.response.statusCode = res.statusCode;
    [self.data setLength:0];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.data appendData:data];
}

@end
