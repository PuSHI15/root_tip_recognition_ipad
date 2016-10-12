//
//  modelClass.m
//  finalProject_iOS
//
//  Created by 石璞 on 09/05/2014.
//  Copyright (c) 2014 Pu SHI. All rights reserved.
//

#import "modelClass.h"

@implementation modelClass

@synthesize image;
@synthesize DescriptorDim;
@synthesize indexForPos, indexForNeg, pospicName, negpicName, rtIndex, nrtIndex;
@synthesize temp;

@synthesize selectedRTips = _selectedRTips;
@synthesize selectedNRTips = _selectedNRTips;



- (NSMutableArray *)selectedRTips {
    if (!_selectedRTips)
        _selectedRTips = [[NSMutableArray alloc] init];
    return _selectedRTips;
}

- (NSMutableArray *)selectedNRTips {
    if (!_selectedNRTips)
        _selectedNRTips = [[NSMutableArray alloc] init];
    return _selectedNRTips;
}




@end
