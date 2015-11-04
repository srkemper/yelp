//
//  FilterSwitchCell.m
//  Yelp
//
//  Created by Sean Kemper on 11/2/15.
//  Copyright © 2015 codepath. All rights reserved.
//

#import "FilterSwitchCell.h"

@interface FilterSwitchCell ()

@property (weak, nonatomic) IBOutlet UISwitch *filterSwitch;
- (IBAction)filterValueChanged:(id)sender;

@end

@implementation FilterSwitchCell

- (void)awakeFromNib {
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)filterValueChanged:(id)sender {
    [self.delegate filterSwitchCell:self didUpdateValue:self.filterSwitch.on];
}

-(void)setOn:(BOOL)on {
    [self setOn:on animated:NO];
}

-(void)setOn:(BOOL)on animated:(BOOL)animated {
    _on = on;
    [self.filterSwitch setOn:on animated:animated];
}

@end
