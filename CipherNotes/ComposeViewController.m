//
//  ComposeViewController.m
//  CipherNotes
//
//  Created by David Massey on 8/14/11.
//  Copyright 2011 N/A. All rights reserved.
//


#import "ComposeViewController.h"
#import "ContactList.h"
#import "CryptoUtils.h"
#import "ClientServerComm.h"
#import "Message.h"
#import "NSString+URLEncoding.h"
#import "NSData+Base64.h"

@implementation ComposeViewController
@synthesize cancelButton;
@synthesize sendButton;
@synthesize navBar;
@synthesize subjectTextField;
@synthesize toTextField;
@synthesize minToExpireTextField;
@synthesize msgTextView;
@synthesize scrollView;
@synthesize contactList;
@synthesize selectedContact;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        contactList = nil;
    }
    return self;
}

- (IBAction)cancelButtonPressed:(id)sender {
    [self.view removeFromSuperview];
}

- (IBAction)contactListPressed:(id)sender {
    if(contactList == nil) {
        ContactList *ls = [[ContactList alloc] initWithNibName:@"ContactList" bundle:nil];
        self.contactList = ls;
        self.contactList.composeViewController = self;
        [ls release];
    }
        
    [self.view insertSubview: contactList.view atIndex:0];
    [self.view bringSubviewToFront: contactList.view];
}

- (IBAction)sendButtonPressed:(id)sender {
    NSLog(@"mert");
    
    if(selectedContact == nil)
        return;
    
    NSString *minToExpire = [minToExpireTextField text];
    
    NSDate *date = [NSDate date];
    
    NSLocale *locale = [[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] autorelease];
    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
    [formatter setLocale:locale];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    
    NSString *servNow     = [formatter stringFromDate:date];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            [ClientServerComm userId], FROMID_KEY, 
                            [subjectTextField text], SUBJECT_KEY, 
                            [selectedContact contactId], TOID_KEY,
                            [toTextField text], TONAME_KEY,
                            servNow, SENT_KEY, 
                            minToExpire, EXPIRES_KEY, nil];
    
    SecDefMessage *message = [SecDefMessage messageFromHeaders:params];
    [message setMessage:[msgTextView text]];
    
    NSLog(@"New Message Format\r\n%@", [message asString]);
    
    unsigned char aeskey[AES_KEYSIZE_BYTES];
    memset(aeskey, 0, AES_KEYSIZE_BYTES);
    [CryptoUtils generateAESKey: aeskey];
    
    unsigned char aesp1[AES_KEYSIZE_BYTES/2];
    unsigned char aesp2[AES_KEYSIZE_BYTES/2];
    
    memcpy(aesp1, aeskey, AES_KEYSIZE_BYTES/2);
    memcpy(aesp2, aeskey+(AES_KEYSIZE_BYTES/2), AES_KEYSIZE_BYTES/2);
    
    [message sendToService:aeskey];
    printf("\n");
    for(int i=0; i < AES_KEYSIZE_BYTES; i++) {
        printf("%x", aeskey[i]);
    }
    printf("\n");
    
    NSData   *aesDataForDb = [[NSData alloc] initWithBytes:aesp1 length:AES_KEYSIZE_BYTES/2];
    
    NSData   *aesDataForEmail = [[NSData alloc] initWithBytes:aesp2 length:AES_KEYSIZE_BYTES/2];
    NSString *aesTextForEmail = [[aesDataForEmail base64EncodedString] urlEncode];
    
    NSLog(@"aes plain bytes p1: %@", aesDataForDb);
    NSLog(@"aes plain bytes p2: %@", aesDataForEmail);
    
    NSString *receiverPubKeyStr = [ClientServerComm getPublicKey:[selectedContact contactId]];
    RSA      *receiverPubKeyRSA = [CryptoUtils getPublicKeyFromString:receiverPubKeyStr];
    NSString *cipherAESData = [CryptoUtils encryptDataAndBase64Encode:aesDataForDb withPubKey:receiverPubKeyRSA];
    
    NSString *msgid = [[NSNumber numberWithLong:[message msgid]] stringValue];
    
    [ClientServerComm sendKey:cipherAESData messageId: msgid expires:minToExpire];
    
    [ClientServerComm getKey:msgid];
    
    if ([MFMailComposeViewController canSendMail]) {
        
        NSString *path = [[NSBundle mainBundle] pathForResource:@"HtmlEmailContent" ofType:@"html"];
        NSLog(@"path=%@", path);
        NSError *error;
        
        NSString *rawformat = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
        NSString *html = [NSString stringWithFormat:rawformat, message.msgid, aesTextForEmail, message.msgid, aesTextForEmail, @"abc"];
        
        MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
        mailViewController.mailComposeDelegate = self;
        [mailViewController setToRecipients:[NSArray arrayWithObject:[selectedContact name]]];
        [mailViewController setSubject:[subjectTextField text]];
        [mailViewController setMessageBody:html isHTML:YES];
        
        [self presentModalViewController:mailViewController animated:YES];
        [mailViewController release];
    }
    [aesDataForEmail release];
}

-(void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
	[self dismissModalViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(keyboardWillShow:) 
                                                 name:UIKeyboardWillShowNotification 
                                               object:self.view.window];
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(keyboardWillHide:) 
                                                 name:UIKeyboardWillHideNotification 
                                               object:self.view.window];
}

- (void)keyboardWillHide:(NSNotification *)n
{
    NSLog(@"keyboard hiding");
}

- (void)keyboardWillShow:(NSNotification *)n
{
    NSLog(@"keyboard showing");
    
}


- (void)viewDidAppear:(BOOL)animated {
    [navBar setHidden: NO];
}

- (void)viewDidUnload
{
    [self setCancelButton:nil];
    [self setSendButton:nil];
    [self setNavBar:nil];
    [self setSubjectTextField:nil];
    [self setToTextField:nil];
    [self setMinToExpireTextField:nil];
    [self setMsgTextView:nil];
    [self setScrollView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [cancelButton release];
    [sendButton release];
    [navBar release];
    [subjectTextField release];
    [toTextField release];
    [minToExpireTextField release];
    [msgTextView release];
    [scrollView release];
    [super dealloc];
}

@end
