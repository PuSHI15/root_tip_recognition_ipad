//
//  modelClass.h
//  finalProject_iOS
//
//  Created by 石璞 on 09/05/2014.
//  Copyright (c) 2014 Pu SHI. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface modelClass : NSObject


@property(nonatomic, retain) NSMutableArray *selectedRTips;
@property(nonatomic, retain) NSMutableArray *selectedNRTips;
@property int DescriptorDim;
@property NSUInteger indexForPos, indexForNeg, pospicName, negpicName, rtIndex, nrtIndex;
@property CGPoint temp;
@property(nonatomic, retain) UIImage *image;

@end
