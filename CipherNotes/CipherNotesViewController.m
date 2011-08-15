//
//  CipherNotesViewController.m
//  CipherNotes
//
//  Created by David Massey on 8/14/11.
//  Copyright 2011 N/A. All rights reserved.
//

#import "CipherNotesViewController.h"
#import "ComposeViewController.h"
#import "ReadMessageController.h"
#import "ClientServerComm.h"
#import "AppData.h"
#import "CryptoUtils.h"
#import "MessageList.h"

@implementation CipherNotesViewController

@synthesize readMessageController;
@synthesize composeViewController;
@synthesize messageList;

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [ClientServerComm setUserId:2];
    
    [CryptoUtils seedPRNG]; 
    
    BOOL isRegistered = [ClientServerComm isActivated];
    if(!isRegistered) {
        NSLog(@"Activating");
        RSA *rsa = [CryptoUtils generateKeyPair];
        NSString *pubkey = [CryptoUtils getPublicKey:rsa];
        
        [ClientServerComm activate:pubkey]; 
        AppData *appData = [AppData appData];
        [appData savePrivateKey:[CryptoUtils getPrivateKey:rsa]];
        
        NSLog(@"Activation Successful");
    } else {
        NSLog(@"Activated");
    }
}

- (void) loadMessage:(SecDefMessage *)message {
    if(self.readMessageController == nil) {
        ReadMessageController *cc = [[ReadMessageController alloc] initWithNibName:@"ReadMessageController" bundle:nil];
        self.readMessageController = cc;
        [cc release];
    }
    
    if(self.composeViewController.view.superview != nil) {
        [self.composeViewController.view removeFromSuperview];
    }
    
    [self.view insertSubview:self.readMessageController.view atIndex:0];
    [self.view bringSubviewToFront:readMessageController.view];
    [self.readMessageController.messageTextView setText:message.message];
    
}

- (IBAction)inboxButtonPushed:(id)sender {
    if(self.messageList == nil) {
        MessageList *cc = [[MessageList alloc] initWithNibName:@"MessageList" bundle:nil];
        self.messageList = cc;
        self.messageList.mainController = self;
        [cc release];
    }
    
    [self.view insertSubview:self.messageList.view atIndex:0];
    [self.view bringSubviewToFront:self.messageList.view];
    [self.messageList viewDidAppear:NO];
}

- (IBAction)composeButtonPushed:(id)sender {
   
    if(self.composeViewController == nil) {
        ComposeViewController *cc = [[ComposeViewController alloc] initWithNibName:@"ComposeViewController" bundle:nil];
        self.composeViewController = cc;
        [cc release];
    }
    [self.view insertSubview:self.composeViewController.view atIndex:0];
    [self.view bringSubviewToFront:composeViewController.view];
}

- (void)viewDidUnload
{
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
    [super dealloc];
}
@end
