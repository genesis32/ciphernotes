//
//  MessageList.h
//  secdef
//
//  Created by David Massey on 7/18/11.
//  Copyright 2011 N/A. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CipherNotesViewController;

@interface MessageList : UIViewController {
    NSMutableArray *listOfMessages;
    CipherNotesViewController *mainController;
}
@property (nonatomic, retain) IBOutlet UINavigationController *navController;
@property (nonatomic, retain) CipherNotesViewController *mainController;
@end
