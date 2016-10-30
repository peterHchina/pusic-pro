//
//  NPView.m
//  NPCustomWindowButton
//
//  Created by 樊航宇 on 15/4/8.
//  Copyright (c) 2015年 樊航宇. All rights reserved.
//

#import "NPView.h"

@implementation NPView

-(instancetype)initWithFrame:(NSRect)frameRect
{
    self=[super initWithFrame:frameRect];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationViewChanged:) name:NSViewFrameDidChangeNotification object:self];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationViewChanged:) name:NSViewBoundsDidChangeNotification object:self];
        
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    NSBezierPath *path=[NSBezierPath new];
    if (_bgColor) {
        [_bgColor setFill];
    }else
    {
        [[NSColor blackColor]setFill];
    }
    
    [path appendBezierPathWithRoundedRect:[self bounds] xRadius:5.0 yRadius:5.0];
    [path fill];
    
    
    // Drawing code here.
}

- (void)notificationViewChanged:(NSNotification *)notification
{
    [self setNeedsDisplay:YES];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
@end
