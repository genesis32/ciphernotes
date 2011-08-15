//
//  CipherNotesViewController.h
//  CipherNotes
//
//  Created by David Massey on 8/14/11.
//  Copyright 2011 N/A. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ComposeViewController;
@class ReadMessageController;
@class SecDefMessage;

@interface CipherNotesViewController : UIViewController {
    ComposeViewController *composeViewController;
    ReadMessageController *readMessageController;
    UINavigationBar *navBar;
}

@property (retain, nonatomic) ComposeViewController *composeViewController;
@property (retain, nonatomic) ReadMessageController *readMessageController;

- (void) loadMessage:(SecDefMessage *)message;

@end


