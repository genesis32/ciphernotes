//
//  MessageList.m
//  secdef
//
//  Created by David Massey on 7/18/11.
//  Copyright 2011 N/A. All rights reserved.
//

#import "MessageList.h"
#import "CipherNotesViewController.h"
#import "Message.h"
#import "MessageListCell.h"
#import "CipherNotesAppDelegate.h"

@implementation MessageList
@synthesize navController;
@synthesize mainController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)dealloc
{
    [listOfMessages release];
    [navController release];
    [navController release];
    [super dealloc];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView 
 numberOfRowsInSection:(NSInteger)section {
    return [listOfMessages count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 78.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView 
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"MessageListCellIdentifier";
    static NSString *CellNib = @"MessageListCell";
    
    MessageListCell *cell = (MessageListCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:CellNib owner:nil options:nil];
        cell = (MessageListCell *)[nib objectAtIndex:0];
    }
    
    SecDefMessage *sdMsg = (SecDefMessage *)[listOfMessages objectAtIndex:[indexPath row]];
    
    [[cell fromField] setText:@"from"];
    [[cell previewField] setText:sdMsg.message];
    [[cell dateField] setText:@"textfield"];
    
    return cell;
}
- (IBAction)donePressed:(id)sender {
    [self.view removeFromSuperview];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SecDefMessage *msg = (SecDefMessage *)[listOfMessages objectAtIndex:indexPath.row];
    [mainController loadMessage: msg];
    NSLog(@"selected message!");
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidAppear:(BOOL)animated {
    
    NSLog(@"view did appear!");
    
    CipherNotesAppDelegate *del = (CipherNotesAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [del managedObjectContext];
    NSError *err = nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription 
                                   entityForName:@"Message" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    listOfMessages = [[NSMutableArray alloc] init];
    
    NSArray *fetchedObjects = [[context executeFetchRequest:fetchRequest error:&err] retain];
    for (NSManagedObject *info in fetchedObjects) {
        SecDefMessage *plainMessage = [SecDefMessage messageFromSave:info];
        if(plainMessage == nil) {
            [context deleteObject:info];
        } else {
            [listOfMessages addObject:plainMessage];
        }
    }        
    [fetchRequest release];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.    

}

- (void)viewDidUnload
{
    [navController release];
    navController = nil;
    [self setNavController:nil];
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
