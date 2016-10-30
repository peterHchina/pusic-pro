//
//  NPCustomWindow.h
//  NPCustomWindowButton
//
//  Created by 樊航宇 on 15/4/8.
//  Copyright (c) 2015年 樊航宇. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NPCustomWindow : NSWindow
@property (nonatomic) NSButton *closeButton;
@property (nonatomic) NSButton *minButton;
@property (nonatomic) NSButton *maxButton;

@end
