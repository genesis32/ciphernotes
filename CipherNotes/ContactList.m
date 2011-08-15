//
//  ContactList.m
//  secdef
//
//  Created by David Massey on 7/8/11.
//  Copyright 2011 N/A. All rights reserved.
//

#import "ContactList.h"
#import "Contact.h"
#import "ClientServerComm.h"
#import "ComposeViewController.h"

@implementation ContactList

@synthesize contactListTable;
@synthesize selectedContact;
@synthesize composeViewController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        selectedContact = nil;
    }
    return self;
}

- (void)dealloc
{
    [contactListTable release];
    [listOfContacts release];
    [super dealloc];
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
    
    listOfContacts = [ClientServerComm getContactList];
    [listOfContacts retain];
}
     
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView 
 numberOfRowsInSection:(NSInteger)section {
    return [listOfContacts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView 
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    cell.textLabel.text = [(Contact *)[listOfContacts objectAtIndex:indexPath.row] name];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView 
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    selectedContact = [listOfContacts objectAtIndex:indexPath.row];
    NSLog(@"Selected Contact: id=%@ name=%@", [selectedContact contactId], [selectedContact name]); 
    composeViewController.selectedContact = selectedContact;
    [composeViewController.toTextField setText:[selectedContact name]];
    [self.view removeFromSuperview];
}

- (void)viewDidUnload
{
    [self setContactListTable:nil];
    [listOfContacts release];
    [super viewDidUnload];

    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
