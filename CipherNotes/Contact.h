//
//  Contact.h
//  secdef
//
//  Created by David Massey on 7/8/11.
//  Copyright 2011 N/A. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Contact : NSObject {
    NSString  *contactId;
    NSString  *name;
}

+(Contact *) contactFromData:(NSString *) cId andName:(NSString *)cName;

@property (nonatomic, retain) NSString *contactId;
@property (nonatomic, retain) NSString *name;

@end
