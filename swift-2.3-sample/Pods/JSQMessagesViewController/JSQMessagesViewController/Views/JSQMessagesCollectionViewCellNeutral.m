//
//  JSQMessagesCollectionViewCellNeutral.m
//  JSQMessages
//
//  Created by Jed Kyung on 8/10/16.
//  Copyright © 2016 Hexed Bits. All rights reserved.
//

#import "JSQMessagesCollectionViewCellNeutral.h"

@implementation JSQMessagesCollectionViewCellNeutral

#pragma mark - Overrides

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.messageBubbleTopLabel.textAlignment = NSTextAlignmentCenter;
    self.cellBottomLabel.textAlignment = NSTextAlignmentCenter;
}

@end
