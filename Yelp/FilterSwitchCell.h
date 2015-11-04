//
//  FilterSwitchCell.h
//  Yelp
//
//  Created by Sean Kemper on 11/2/15.
//  Copyright © 2015 codepath. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FilterSwitchCell;

@protocol FilterSwitchCellDelegate <NSObject>

- (void)filterSwitchCell:(FilterSwitchCell *)cell didUpdateValue:(BOOL)value;

@end

@interface FilterSwitchCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *filterLabel;
@property (nonatomic, assign) BOOL on;

@property (nonatomic, weak) id<FilterSwitchCellDelegate> delegate;
-(void)setOn:(BOOL)on animated:(BOOL)animated;
@end
