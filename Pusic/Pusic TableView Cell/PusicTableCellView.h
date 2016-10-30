//
//  PusicTableCellView.h
//  Pusic Lite
//
//  Created by peter on 15/8/9.
//  Copyright (c) 2015年 peter. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PusicTableCellView : NSTableCellView
@property (strong) IBOutlet NSTextField *musicName;
@property (strong) IBOutlet NSTextField *musicArter;
@property (strong) IBOutlet NSTextField *musictime;

@end
