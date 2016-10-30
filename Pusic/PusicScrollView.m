//
//  PusicScrollView.m
//  Pusic
//
//  Created by peter on 15/10/20.
//  Copyright © 2015年 peter. All rights reserved.
//

#import "PusicScrollView.h"

@implementation PusicScrollView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    NSBezierPath *path=[NSBezierPath new];
    NSBezierPath *path1=[NSBezierPath new];
    NSRect rect = self.bounds;
    [self.backgroundColor setFill];
    NSRect upRect = NSMakeRect(rect.origin.x
                               , rect.size.height-10, rect.size.width, 10);
    NSRect downRect = NSMakeRect(rect.origin.x
                                 , rect.origin.y, rect.size.width, rect.size.height-10);
    [path appendBezierPathWithRoundedRect:[self bounds] xRadius:5.0 yRadius:5.0];
    [path fill];
    [path1 appendBezierPathWithRoundedRect:downRect xRadius:5.0 yRadius:5.0];
    [path1 fill];
    // Drawing code here.
}

@end
