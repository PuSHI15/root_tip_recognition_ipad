//
//  viewToDisplay.m
//  finalProject_iOS
//
//  Created by 石璞 on 15/03/2014.
//  Copyright (c) 2014 Pu SHI. All rights reserved.
//

#import "viewToDisplay.h"
#import "RootTips.h"
#import "Non_RootTips.h"


@implementation viewToDisplay

@synthesize model = _model;

- (modelClass *)model {
    if (!_model)
        _model = [[modelClass alloc] init];
    return _model;
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    for (RootTips *rt in _model.selectedRTips) {
        //NSLog(@"drawRect called ,%f %f %f %f",rect.origin.x,rect.origin.y,rect.size.width,rect.size.height);
        CGContextRef ref=UIGraphicsGetCurrentContext();
        CGContextAddRect(ref, CGRectMake(rt.centerPoint.x-(rt.width/2), rt.centerPoint.y-(rt.height/2), rt.width, rt.height));
        CGContextSetStrokeColorWithColor(ref,[UIColor redColor].CGColor);
        CGContextSetLineWidth(ref,0.5);
        CGContextStrokePath(ref);
    }
    
    for (Non_RootTips *nrt in _model.selectedNRTips) {
        //NSLog(@"drawRect called ,%f %f %f %f",rect.origin.x,rect.origin.y,rect.size.width,rect.size.height);
        CGContextRef ref=UIGraphicsGetCurrentContext();
        CGContextAddRect(ref, CGRectMake(nrt.centerPoint.x-(nrt.width/2), nrt.centerPoint.y-(nrt.height/2), nrt.width, nrt.height));
        CGContextSetStrokeColorWithColor(ref,[UIColor yellowColor].CGColor);
        CGContextSetLineWidth(ref,0.5);
        CGContextStrokePath(ref);
    }
    
    
}

@end
