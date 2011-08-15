//
//  MessageListCell.h
//  secdef
//
//  Created by David Massey on 7/21/11.
//  Copyright 2011 N/A. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MessageListCell : UITableViewCell {
    UILabel *fromField;
    UILabel *previewField;
    UILabel *dateField;
}

@property (nonatomic, retain) IBOutlet UILabel *fromField;
@property (nonatomic, retain) IBOutlet UILabel *previewField;
@property (nonatomic, retain) IBOutlet UILabel *dateField;

@end
