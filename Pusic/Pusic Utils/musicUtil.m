//
//  musicUtil.m
//  Pusic
//
//  Created by peter on 15/10/24.
//  Copyright © 2015年 peter. All rights reserved.
//

#import "musicUtil.h"
#import "Music.h"
#import <AppKit/AppKit.h>
#import <AVFoundation/AVFoundation.h>
@implementation musicUtil
+(NSImage *) getSongCoverImage:(Music * )music
{
    NSMutableDictionary *retDic = [[NSMutableDictionary alloc] init];
    NSURL *musicURL = [NSURL fileURLWithPath:music.musicPathURL];
    NSImage *image ;
    AVURLAsset *musicAsset = [AVURLAsset URLAssetWithURL:musicURL options:nil];
    
    //    NSLog(@"%@",mp3Asset);
    
    for (NSString *format in [musicAsset availableMetadataFormats]) {
        for (AVMetadataItem *metadataItem in [musicAsset metadataForFormat:format]) {
            
            if(metadataItem.commonKey )
                [retDic setObject:metadataItem.value forKey:metadataItem.commonKey];
            
        }
    }
    NSData *data =[retDic objectForKey:@"artwork"] ;
    image =[[NSImage alloc] initWithData:data];
    return image;
    
}



+(NSString *) getFormateTimeString : (NSInteger ) time
{
    NSLog(@"time %ld",time);
    int minute=0;
    int second=0;
    if (time>=60) {
        int index = (int)time/60;
        minute = index;
        second=(int)time -60*index;
    }else
    {
        second = (int)time;
    }
    NSString *minuteString=@"00";
    NSString *secondString=@"00";
    
    if (minute<10) {
        minuteString= [NSString stringWithFormat:@"%d",minute];
    }
    else
    {
        minuteString= [NSString stringWithFormat:@"%d",minute];
        
    }
    if (second<10) {
        secondString=[NSString stringWithFormat:@"0%d",second];
        
    }else
    {
        secondString=[NSString stringWithFormat:@"%d",second];
    }
    
    
    
    return  [NSString stringWithFormat:@"%@:%@",minuteString,secondString];
    
}

+(NSString *) getSongTime:(AVURLAsset *) urlAsset :(Music *) music
{
    
    if(urlAsset)
    {
        double musicTime = urlAsset.duration.value/urlAsset.duration.timescale;
        [music setMusicRealTime:musicTime];
        return  [self getFormateTimeString:(int)musicTime];
    }
    return @"0s";
}


@end
