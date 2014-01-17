//
//  MPrintRequest.h
//  BluePrinter
//
//  Created by David Paul Quesada on 1/14/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

// https://mprint.umich.edu/api/users - returns logged in info.
//  if user is logged in, status code = 200,
//  else, status code = 302

// https://weblogin.umich.edu - Login page
//  If user is logged in, will return HTTP 302. (to redirect to a "services" page)

// https://weblogin.umich.edu/cosign-bin/logout - Logout page/command.
// If you GET, it returns the standard logout confirmation page.
    // HTTP 200
// If you POST, you actually do the logout.
    // HTTP 302

// https://weblogin.umich.edu/cosign-bin/cosign.cgi?ref=&service=&required=&login=dquesada&password=wrong
// TODO: See if we can POST to this.
// - Returns 200 if wrong password (i.e. return the normal login page w/ 'wrong' message)
// - Returns 302 if successful (i.e. redirects to "services" page)

// Curl command (copied from chrome).
// https://weblogin.umich.edu/cosign-bin/cosign.cgi' -H 'Cookie: cosign-weblogin=w3O6zqOZp89o8onLo+ju6ZCdJXOwlsTjwRw4+SzojJOmfdfxl4iR2muZRh3-NUJxHEWNHMNlHovqt8ZIFgy41An17WtZayQO9iQet1gPAJYuowHmVmM8nJBTNmBu/1389760763; cosign=6EIEGeQ7d4hHXUuTQsSZ5lQ5KqYNx8XreX-03SLl4U3GhITrPJ+bblQrPWzUEjuxTvgcmDmo-4eDguA2JqHw-NrK4Wg74orHqJDDMYeWcunPdUKd1Dl7SvNt-EhB/1389760877' -H 'Origin: https://weblogin.umich.edu' -H 'Accept-Encoding: gzip,deflate,sdch' -H 'Host: weblogin.umich.edu' -H 'Accept-Language: en-US,en;q=0.8' -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/31.0.1650.63 Safari/537.36' -H 'Content-Type: application/x-www-form-urlencoded' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8' -H 'Cache-Control: max-age=0' -H 'Referer: https://weblogin.umich.edu/' -H 'Connection: keep-alive' --data 'ref=&service=&required=&login=dquesada&password=wrong&tokencode=' --compressed




#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, Method)
{
    MethodNone,
    POST,
    GET,
    PUT,
    DELETE,
};

@class MPrintResponse;

@interface MPrintRequest : NSObject

+(NSString *)baseURL;

-(instancetype)initWithEndpoint:(NSString *)endpoint; // Default to GET
-(instancetype)initWithEndpoint:(NSString *)endpoint method:(Method)method;

-(void)perform:(void (^)(MPrintResponse *response))completion;

@end
