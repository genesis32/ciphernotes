//
//  MessageListCell.m
//  secdef
//
//  Created by David Massey on 7/21/11.
//  Copyright 2011 N/A. All rights reserved.
//

#import "MessageListCell.h"


@implementation MessageListCell
@synthesize fromField;
@synthesize previewField;
@synthesize dateField;

- (void)dealloc
{
    [fromField release];
    [previewField release];
    [dateField release];
    [super dealloc];
}

@end
