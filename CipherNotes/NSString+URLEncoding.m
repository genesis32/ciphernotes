//
//  NSString+URLEncoding.m
//  secdef
//
//  Created by David Massey on 7/2/11.
//  Copyright 2011 N/A. All rights reserved.
//

#import "NSString+URLEncoding.h"


@implementation NSString (URLEncoding)

-(NSString *)urlEncode {
	return (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,
                                                               (CFStringRef)self,
                                                               NULL,
                                                               (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
                                                               CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
}

@end
