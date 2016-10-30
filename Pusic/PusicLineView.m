//
//  PusicImageView.m
//  Pusic
//
//  Created by peter on 15/10/20.
//  Copyright © 2015年 peter. All rights reserved.
//

#import "PusicLineView.h"

@implementation PusicLineView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    NSBezierPath *path=[NSBezierPath new];    
    [[NSColor colorWithCalibratedRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1]setFill];
    [path appendBezierPathWithRoundedRect:[self bounds] xRadius:0.0 yRadius:0.0];
    [path fill];
    // Drawing code here.
}

@end
