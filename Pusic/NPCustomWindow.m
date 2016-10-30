//
//  NPCustomWindow.m
//  NPCustomWindowButton
//
//  Created by 樊航宇 on 15/4/8.
//  Copyright (c) 2015年 樊航宇. All rights reserved.
//

#import "NPCustomWindow.h"
#import "_NSThemeWidgetCell.h"
#import <objc/runtime.h>

__weak NPCustomWindow *myWindow;  //point to our window object
CFStringRef (* originalIMP)(id self, SEL _cmd);    //the original coreUIWidgetState;
BOOL hover=NO;				//indicates rollover state


static CFStringRef myCoreUIWidgetState(id self, SEL _cmd)
{
    if (self==myWindow.maxButton.cell || self==myWindow.minButton.cell || self==myWindow.closeButton.cell) {
        if (((NSButtonCell *)self).highlighted) {
            return (__bridge CFStringRef)@"pressed";
        }
        return hover?(__bridge CFStringRef)@"rollover":(__bridge CFStringRef)@"normal";
    }
    
    return originalIMP(self,_cmd);
}

@implementation NPCustomWindow

@synthesize closeButton,minButton,maxButton;

-(void)awakeFromNib
{
    // Set pointer
    myWindow=self;
    [self setMovableByWindowBackground:YES];
    // Method Swizzling
    Method coreUIWidgetStateMethod=class_getInstanceMethod([_NSThemeWidgetCell class], @selector(coreUIState));
    const char *encoding=method_getTypeEncoding(coreUIWidgetStateMethod);
    originalIMP=(void*)method_getImplementation(coreUIWidgetStateMethod);
    class_replaceMethod([_NSThemeWidgetCell class], @selector(coreUIState), (IMP)myCoreUIWidgetState, encoding);
    
    // Set window to transparent
    self.opaque=NO;
    self.backgroundColor=[NSColor clearColor];
    
    // get buttons
    closeButton=[NSWindow standardWindowButton:NSWindowCloseButton forStyleMask:0 ];
    minButton=[NSWindow standardWindowButton:NSWindowMiniaturizeButton forStyleMask:0 ];
    maxButton=[NSWindow standardWindowButton:NSWindowZoomButton forStyleMask:0 ];
    
    // attach buttons
    [self.contentView  addSubview:closeButton];
    [self.contentView  addSubview:minButton];
//    [self.contentView  addSubview:maxButton];
    
    // move buttons
    [minButton setFrameOrigin:CGPointMake(28, [self.contentView frame].size.height-minButton.frame.size.height-8)];
    [closeButton setFrameOrigin:CGPointMake(8, [self.contentView frame].size.height-closeButton.frame.size.height-8)];
    [maxButton setFrameOrigin:CGPointMake(48, [self.contentView frame].size.height-closeButton.frame.size.height-8)];
    
    //set tracking area
    NSTrackingArea *trackingArea=[[NSTrackingArea alloc]initWithRect:CGRectMake(0, 0, closeButton.frame.size.width*3.5, closeButton.frame.size.height) options:NSTrackingActiveAlways|NSTrackingMouseEnteredAndExited owner:self userInfo:nil];
    [closeButton addTrackingArea:trackingArea];
}

-(void)mouseEntered:(NSEvent *)theEvent
{
    hover=YES;
    [self setTitleButtonsNeedDisplay];
}

-(void)mouseExited:(NSEvent *)theEvent
{
    hover=NO;
    [self setTitleButtonsNeedDisplay];
}

-(BOOL)canBecomeKeyWindow
{
    return YES;
}

-(void)setTitleButtonsNeedDisplay
{
    [closeButton setNeedsDisplay:YES];
    [maxButton setNeedsDisplay:YES];
    [minButton setNeedsDisplay:YES];
}

-(void)becomeKeyWindow
{
    [super becomeKeyWindow];
    [self setTitleButtonsNeedDisplay];
}

-(void)resignKeyWindow
{
    [super resignKeyWindow];
    [self setTitleButtonsNeedDisplay];
}

-(void)dealloc
{
    // Method Swizzling back
    // Maybe unsafe. If other callers use Method Swizzling again after ours, this would discard the latter's Method Swizzling, and if other callers use Method Swizzling before us, and put it back after our uses of Method Swizzling, unexpected result would happen. So you should take care of this use, or lazily, do not exchange the IMP back...
    Method coreUIWidgetStateMethod=class_getInstanceMethod([_NSThemeWidgetCell class], @selector(coreUIState));
    const char *encoding=method_getTypeEncoding(coreUIWidgetStateMethod);
    class_replaceMethod([_NSThemeWidgetCell class], @selector(coreUIState), (IMP)originalIMP, encoding);
}
@end
