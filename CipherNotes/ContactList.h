//
//  ContactList.h
//  secdef
//
//  Created by David Massey on 7/8/11.
//  Copyright 2011 N/A. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Contact.h"

@class ComposeViewController;

@interface ContactList : UIViewController {
    
    UITableView *contactListTable;
    NSArray     *listOfContacts;
    
    Contact *selectedContact;
    ComposeViewController *composeViewController;
}

@property (nonatomic, retain) ComposeViewController *composeViewController;

@property (nonatomic, retain) IBOutlet UITableView *contactListTable;
@property (nonatomic, readonly) Contact *selectedContact;

@end
