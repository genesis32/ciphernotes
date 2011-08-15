//
//  ComposeViewController.h
//  CipherNotes
//
//  Created by David Massey on 8/14/11.
//  Copyright 2011 N/A. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@class ContactList;
@class Contact;

@interface ComposeViewController : UIViewController<MFMailComposeViewControllerDelegate> {
    UIBarButtonItem *cancelButton;
    UIBarButtonItem *sendButton;
    UINavigationBar *navBar;
    UITextField *subjectTextField;
    UITextField *toTextField;
    UITextField *minToExpireTextField;
    UITextView *msgTextView;
    UIScrollView *scrollView;
    ContactList  *contactList;
    
    Contact *selectedContact;
}

@property (nonatomic, retain) IBOutlet UIBarButtonItem *cancelButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *sendButton;
@property (nonatomic, retain) IBOutlet UINavigationBar *navBar;
@property (nonatomic, retain) IBOutlet UITextField *subjectTextField;
@property (nonatomic, retain) IBOutlet UITextField *toTextField;
@property (nonatomic, retain) IBOutlet UITextField *minToExpireTextField;
@property (nonatomic, retain) IBOutlet UITextView *msgTextView;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;

@property (nonatomic, retain) ContactList *contactList;
@property (nonatomic, retain) Contact     *selectedContact;

@end
