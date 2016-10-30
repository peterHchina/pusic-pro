//
//  musicUtil.h
//  Pusic
//
//  Created by peter on 15/10/24.
//  Copyright © 2015年 peter. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Music;
#import <AVFoundation/AVFoundation.h>
@interface musicUtil : NSObject
+(NSImage *) getSongCoverImage:(Music * )music;
+(NSString *) getSongTime:(AVURLAsset *) urlAsset :(Music *) music;
+(NSString *) getFormateTimeString : (NSInteger ) time;
@end
