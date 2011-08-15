//
//  Contact.m
//  secdef
//
//  Created by David Massey on 7/8/11.
//  Copyright 2011 N/A. All rights reserved.
//

#import "Contact.h"


@implementation Contact

@synthesize contactId;
@synthesize name;

+(Contact *) contactFromData:(NSString *)cId andName:(NSString *)cName {
    Contact *contact = [[[Contact alloc] init] autorelease];
    
    [contact setContactId:cId];
    [contact setName:cName];
    
    return contact;
}


@end
