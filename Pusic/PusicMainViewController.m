//
//  ViewController.m
//  Pusic
//
//  Created by peter on 15/10/6.
//  Copyright © 2015年 peter. All rights reserved.
//

#import "PusicMainViewController.h"
#import "AYProgressIndicator.h"
#import "Pusic AlertView/PusicAlert.h"
#import "Music.h"
#import "CreateDataBase.h"
#import "MusicDao.h"
#import "PusicAlert.h"
#import "PusicUserDefaults.h"
#import "PusicRHStatusItemView.h"
#import "PusicStatusBarViewController.h"
#import "PusicTableCellView.h"
#import "PusicTableRowView.h"
@implementation PusicMainViewController
{
    AYProgressIndicator *progressIndicator;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view.window makeKeyAndOrderFront:nil];
    });
     // Do any additional setup after loading the view.
    _upView.bgColor = [NSColor colorWithCalibratedRed:60.0/255.0 green:60/255.0 blue:60/255.0 alpha:1.0];
    
    _downView.bgColor = [NSColor colorWithCalibratedRed:40/255.0 green:40/255.0 blue:40/255.0 alpha:1.0];
    [_upView setNeedsDisplay:YES];
    [_downView setNeedsDisplay:YES];
    
    progressIndicator = [[AYProgressIndicator alloc] initWithFrame:NSMakeRect(0, 480, 330, 0.5)
                                                     progressColor:[NSColor colorWithCalibratedRed:228/255.0 green:130/255.0 blue:46/255.0 alpha:1.0]
                                                        emptyColor:[NSColor colorWithCalibratedRed:32/255.0 green:32/255.0 blue:32/255.0 alpha:1.0]
                                                          minValue:0
                                                          maxValue:100
                                                      currentValue:0];
    [self.view addSubview:progressIndicator];
    
    _musicType.font = [NSFont fontWithName:@"Tungsten-Medium" size:14.0];
    _musicRate.font = [NSFont fontWithName:@"Tungsten-Medium" size:14.0];
    _musicFormate.font = [NSFont fontWithName:@"Tungsten-Medium" size:14.0];
    _musicCode.font = [NSFont fontWithName:@"Tungsten-Medium" size:14.0];

    //数据初始化
    [[[CreateDataBase alloc] init] createDataBase];
    musicDao = [[MusicDao alloc] init];
    songList = [musicDao getAllMusicList];
    [_songNumber setStringValue:[NSString stringWithFormat:@"%ld首",[songList count]]];
    _player = [[EZAudioPlayer alloc] init];
    
    musicPlayingPosition = [PusicUserDefaults getLastPlaySongPosition];
    if (songList.count>0 && songList[musicPlayingPosition]!=nil) {
        _addSongsInFolderButton.hidden = YES;
        _noSongsText.hidden = YES;
        currentMusic = songList[musicPlayingPosition];
        [self setAudioPlayerFile:musicPlayingPosition];
        [_musicTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:musicPlayingPosition] byExtendingSelection:YES];
        [_musicTableView setTarget:self];
        [_musicTableView setDoubleAction:@selector(playMusic)];
        [_musicTableView scrollRowToVisible:musicPlayingPosition];
                [_musicTableView reloadData];
//        [self setStatusImageAndToolTip];
        
    }else
    {
        [self.musicTableView setHidden:YES];
        [self.downView addSubview:_addSongsInFolderButton];
        [self.downView addSubview:_noSongsText];
    }

}

-(void)  awakeFromNib
{
    NSLog(@"------------------------");
    self.player = [EZAudioPlayer audioPlayerWithDelegate:self];
    [self setupNotifications];
    
    isCirculate = [PusicUserDefaults getCirculate ];
    self.player.shouldLoop = isCirculate;
    [self setCriculateButtonState:isCirculate];
    
    isRandom = [PusicUserDefaults getRandom];
    [self setRandomButtonState:isRandom];
    
    isList = [PusicUserDefaults getList];
    [self setSonglistButtonState:isList];

    popOverDelagate =[[PusicPopOverViewDelagate alloc] init];
    popOverDelagate.viewController.player = self.player;
    
    

}



//播放操作
- (IBAction)buttonPlay:(id)sender {
    
    [self audioPlay:musicPlayingPosition];
    [self updatePlayProgress];
    [self reflashUI];
}

-(IBAction)next:(id)sender {
    
    
    if (isRandom) {
        musicPlayingPosition = arc4random()%[songList count];
    }
    [self audioPlay:musicPlayingPosition+1];
    [self updatePlayProgress];
    [self reflashUI];
}


-(IBAction)pro:(id)sender {
    
    
    if (isRandom) {
        musicPlayingPosition = arc4random()%[songList count];
    }
    [self audioPlay:musicPlayingPosition-1];
    [self updatePlayProgress];
    [self reflashUI];
}

-(void) reflashUI
{
    Music *music1 = songList[musicPlayingPosition];
    self.musicSonger.stringValue = music1.musicSinger;
    self.musicFormate.stringValue = music1.musicType.uppercaseString;
    self.musicName.stringValue = music1.musicName;
    
}

//
+(void) initialize
{
    [PusicUserDefaults registerUserDefaults];
    
}

//状态栏设定
- (void)setStatusImageAndToolTip
{
    _statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:24];
    [_statusItem setHighlightMode:YES];
    _statusView = [[PusicRHStatusItemView alloc] initWithStatusBarItem:_statusItem];
    _statusItem.view = _statusView;
    _statusView.target =self;
    _statusView.action = @selector(mouseClick:);
    popOverDelagate =[[PusicPopOverViewDelagate alloc] init];
    [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
    [[NSUserNotificationCenter defaultUserNotificationCenter] removeAllDeliveredNotifications];
    
    NSImage *image = [NSImage imageNamed:@"status"];
    _statusView.image = image;
    _statusView.alternateImage = image;
    [_statusView.alternateImage setTemplate:YES];
    
}

-(void) mouseClick:(id) sender
{
    
    [popOverDelagate showPopover:sender musicInfo:[songList objectAtIndex:musicPlayingPosition]];
    [NSApp activateIgnoringOtherApps:YES];
}

//监听中心
- (void)setupNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(audioPlayerDidChangeAudioFile:)
                                                 name:EZAudioPlayerDidChangeAudioFileNotification
                                               object:self.player];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(audioPlayerDidChangeOutputDevice:)
                                                 name:EZAudioPlayerDidChangeOutputDeviceNotification
                                               object:self.player];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(audioPlayerDidChangePlayState:)
                                                 name:EZAudioPlayerDidChangePlayStateNotification
                                               object:self.player];
    
    // This notification will only trigger if the player's shouldLoop property is set to NO
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(audioPlayerDidReachEndOfFile:)
                                                 name:EZAudioPlayerDidReachEndOfFileNotification
                                               object:self.player];
    // play button notification
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(audioPlayerPlayNext)
                                                 name:PusicStatusBarViewNext
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(audioPlayerPause)
                                                 name:PusicStatusBarViewPause
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(audioPlayerPlayPro)
                                                 name:PusicStatusBarViewPro
                                               object:nil];
    
}


//------------------------------------------------------------------------------

- (void)audioPlayerDidChangeAudioFile:(NSNotification *)notification
{
    EZAudioPlayer *player = [notification object];
//    NSLog(@"Player changed audio file: %@", [player audioFile]);
    _musicCode.stringValue = [NSString stringWithFormat:@"%.1fkHz",([player audioFile].fileFormat.mSampleRate/1000)];
    _musicRate.stringValue= [NSString stringWithFormat:@"%dkbps",([player audioFile].clientFormat.mBytesPerPacket*[player audioFile].clientFormat.mBitsPerChannel)];
    [self reflashUI];
}

//------------------------------------------------------------------------------

- (void)audioPlayerDidChangeOutputDevice:(NSNotification *)notification
{
    EZAudioPlayer *player = [notification object];
    //    NSLog(@"Player changed output device: %@", [player device]);
}

//------------------------------------------------------------------------------

- (void)audioPlayerDidChangePlayState:(NSNotification *)notification
{
    EZAudioPlayer *player = [notification object];
    NSLog(@"Player change play state, isPlaying: %i", [player isPlaying]);
}

//------------------------------------------------------------------------------

- (void)audioPlayerDidReachEndOfFile:(NSNotification *)notification
{
    //    NSLog(@"Player did reach end of file!");
    if (!isCirculate) {
        if (isRandom) {
            musicPlayingPosition = arc4random()%[songList count];
        }else {
            
            musicPlayingPosition+=1;
            if (musicPlayingPosition==songList.count) {
                musicPlayingPosition =0;
            }
        }
        currentMusic  = [songList objectAtIndex:(musicPlayingPosition)];
        NSIndexSet *set = [NSIndexSet indexSetWithIndex:musicPlayingPosition];
        [self setAudioPlayerFile:musicPlayingPosition];
        [_musicTableView  selectRowIndexes:set byExtendingSelection:NO];
        [_musicTableView scrollRowToVisible:musicPlayingPosition];
        [PusicUserDefaults setLastPlaySongPosition:musicPlayingPosition];
        [self.player play];
    }
    
}

//音乐播放控制

-(void) audioPlayerPlayNext
{
    if (isRandom) {
        musicPlayingPosition = arc4random()%[songList count];
    }
    [self audioPlay:musicPlayingPosition+1];
    
}

-(void) audioPlayerPause
{
    [self audioPlay:musicPlayingPosition];
}

-(void) audioPlayerPlayPro
{
    if (isRandom) {
        musicPlayingPosition = arc4random()%[songList count];
    }
    [self audioPlay:musicPlayingPosition-1];
    
}


-(void) audioPlay: (NSInteger) position
{
    if (position < songList.count && songList!=nil) {
        
        if (musicPlayingPosition == position) {
            
            
            if ([self.player isPlaying]) {
                [self.player pause];
            }else
            {
               if(_player.audioFile==nil)
               {
                     [self setAudioPlayerFile:musicPlayingPosition];
               }
              
                [self.player play];
            }
        }else
        {
            musicPlayingPosition = position;
            [PusicUserDefaults setLastPlaySongPosition:musicPlayingPosition];
            [self setAudioPlayerFile:musicPlayingPosition];
            [self.player play];
            
            NSIndexSet *set = [NSIndexSet indexSetWithIndex:musicPlayingPosition];
            [_musicTableView  selectRowIndexes:set byExtendingSelection:NO];
            [_musicTableView scrollRowToVisible:musicPlayingPosition];
            
        }
    }
    
    
    if ([self.player isPlaying]) {
        [_playButton setImage:[NSImage imageNamed:@"state_play_puse_normal"]];
        [_playButton setAlternateImage:[NSImage imageNamed:@"state_play_puse_pressed"]];
    }else
    {
        [_playButton setImage:[NSImage imageNamed:@"state_play_normal"]];
        [_playButton setAlternateImage:[NSImage imageNamed:@"state_play_pressed"]];
    }
    [_window setTitle:[currentMusic musicName]];
    
    [_musicTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:musicPlayingPosition] byExtendingSelection:NO];
    
}


-(void) setAudioPlayerFile:(NSUInteger) position
{
    NSString *path = [(Music *)songList[position] musicPathURL];
    NSURL *url = [NSURL fileURLWithPath:path];
    self.audioFile = [EZAudioFile audioFileWithURL:url];
    [self.player setAudioFile:self.audioFile];
    if(position<songList.count){
        currentMusic = [songList objectAtIndex:position];
        
    }
}


//更新播放时间以及进度条
-(void) updatePlayProgress
{
    [self removeCurrentTime];
    if (!currentTimer) {
        currentTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updatePlayingTime) userInfo:nil repeats:YES];
        
    }
    
}


-(void) updatePlayingTime
{
    Music *music1 = songList[musicPlayingPosition];
    NSInteger currentTime = [_player currentTime];
    [_musicTimeLabel setStringValue:[NSString stringWithFormat:@"%@",[musicUtil getFormateTimeString:currentTime]]];
    
    double percent = (currentTime/music1.musicRealTime)*100;
    [self count:percent];
}

-(void)count :(double) percent{
    NSLog(@"percent=%lf",percent);
    if (percent<= 100) {
        [progressIndicator setProgressValue:  percent];
    }
    
}



- (void)openFile:(id)sender
{
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    openDlg.canChooseFiles = YES;
    openDlg.canChooseDirectories = NO;
    openDlg.delegate = self;
    if ([openDlg runModal] == NSModalResponseOK)
    {
        NSArray *selectedFiles = [openDlg URLs];
        [self openFileWithFilePathURL:selectedFiles.firstObject];
    }
}

//按文件夹批量加入歌曲action
- (IBAction)addFolder:(id)sender {
    __block NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setCanChooseDirectories:YES];
    [panel setCanChooseFiles:NO];
    [panel setTitle:@"选择歌曲所在文件夹"];
    [panel beginSheetModalForWindow:[self window] completionHandler:^(NSInteger resault)
     {
         if (resault== NSModalResponseOK) {
             [self performSelectorInBackground:@selector(backgroundOperation:) withObject:panel];
         }
         panel = nil;
         
         
     }];
    
}
//删除nstimer
-(void)removeCurrentTime
{
    if (!currentTimer) {
        [currentTimer invalidate];
        //把定时器清空
        currentTimer=nil;
    }
    
}

//快进后退设定
-(void)seekToFrame:(id)sender
{
    double value = [(NSSlider*)sender doubleValue];
    [self.player seekToFrame:(SInt64)value];
    
}


- (BOOL)panel:(id)sender shouldShowFilename:(NSString *)filename
{
    NSString *ext = [filename pathExtension];
    NSArray *fileTypes = [EZAudioFile supportedAudioFileTypes];
    BOOL isDirectory = [ext isEqualToString:@""];
    return [fileTypes containsObject:ext] || isDirectory;
}


//根据歌曲文件URL打开播放
-(void)openFileWithFilePathURL:(NSURL*)filePathURL
{
    //
    // Stop playback
    //
    [self.player pause];
    //
    // Load the audio file and customize the UI
    //
    self.audioFile = [EZAudioFile audioFileWithURL:filePathURL];
    self.playButton.state = NSOffState;
    //
    // Play the audio file
    //
    [self.player setAudioFile:self.audioFile];
}


//删除歌曲按钮action
- (IBAction)clear:(id)sender {
    PusicAlert *alert = [PusicAlert alertWithTitle:@"列表清除警告!" MessageText:@"是否要清除当前歌曲列表？"  okButton:@"确定" cancelButton:@"取消" otherButton:nil imagePath:nil] ;
    
    NSInteger action = [alert RunModel];
    if(action == PusicAlertOkReturn)
    {
        
        [self clearAllData:[alert isDelete] ];
        
    }
    else if(action == PusicAlertCancelReturn )
    {
        NSLog(@"SYXAlertCancelButton clicked!");
    }
    
}


//加歌按钮action
- (IBAction)addSong:(id)sender {
    __block NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setCanChooseDirectories:NO];
    [panel setCanChooseFiles:YES];
    [panel setTitle:@"选择歌曲"];
    [panel setAllowedFileTypes:[NSArray arrayWithObjects:@"mp3",@"wmv", nil]];
    [panel beginSheetModalForWindow:[self window] completionHandler:^(NSInteger resault)
     {
         if (resault== NSModalResponseOK) {
             [self performSelectorInBackground:@selector(backgroundOperation:) withObject:panel];
         }
         panel = nil;
         
         
     }];
    
    
}


- (IBAction)adjustVolume:(id)sender {
    [self.player setVolume:[_volumeSlider floatValue]];
}
//随机按钮action
- (IBAction)shufflePlay:(id)sender {
    if (isRandom) {
        
        
    }else{
        isRandom = !isRandom;
        if (isCirculate) {
            isCirculate = !isCirculate;
            [PusicUserDefaults setCirculate:isCirculate];
            [self setCriculateButtonState:isCirculate];
        }
        
        if (isList) {
            isList = !isList;
            [PusicUserDefaults setList:isList];
            [self setSonglistButtonState:isList];
        }
        
        
        [PusicUserDefaults setRandom:isRandom];
        
        [self setRandomButtonState:isRandom];
    }
    //    [[NSNotificationCenter defaultCenter] postNotificationName:EZAudioPlayerDidChangePlayStateNotification object:self];
    
}
//列表按钮action
- (IBAction)listPlay:(id)sender {
    if (isList) {
        
    }else {
        isList = !isList;
        if (isRandom) {
            isRandom = !isRandom;
            [PusicUserDefaults setRandom:isRandom];
            [self setRandomButtonState:isRandom];
        }
        
        if (isCirculate) {
            isCirculate = !isCirculate;
            [PusicUserDefaults setCirculate:isCirculate];
            [self setCriculateButtonState:isCirculate];
        }
        
        
        [PusicUserDefaults setList:isList];
        
        [self setSonglistButtonState:isList];
    }
    
}

//循环按钮action
- (IBAction)repeatPlay:(id)sender {
    if (isCirculate) {
        
    }else {
        isCirculate = !isCirculate;
        if (isRandom) {
            isRandom = !isRandom;
            [PusicUserDefaults setRandom:isRandom];
            [self setRandomButtonState:isRandom];
        }
        
        if (isList) {
            isList = !isList;
            [PusicUserDefaults setList:isList];
            [self setSonglistButtonState:isList];
        }
        
        [PusicUserDefaults setCirculate:isCirculate];
        
        [self setCriculateButtonState:isCirculate];
    }
    
    
}

//循环按钮状态配置
-(void) setCriculateButtonState:(BOOL) state
{
    if (state == YES) {
        [_repeatButton setImage:[NSImage imageNamed:@"Repeat_press"]];
    }else
    {
        [_repeatButton setImage:[NSImage imageNamed:@"Repeat_normal"]];
    }
    
}
//列表按钮状态配置
-(void) setSonglistButtonState:(BOOL) state
{
    if (state == YES) {
        [_songListButton setImage:[NSImage imageNamed:@"Songlist_press"]];
    }else
    {
        [_songListButton setImage:[NSImage imageNamed:@"Songlist_normal"]];
    }
    
}
//随机按钮状态配置
-(void) setRandomButtonState:(BOOL) state
{
    if (state == YES) {
        [_shuffleButton setImage:[NSImage imageNamed:@"Shuffle_press"]];
    }else
    {
        [_shuffleButton setImage:[NSImage imageNamed:@"Shuffle_normal"]];
    }
    
}

//异步线程数据加载
-(void) backgroundOperation:(id) unused
{
    NSArray * arry = [songList copy];
    NSFileManager *fileManger = [NSFileManager new];
    NSURL *path2;
    NSString *basePath ;
    if ([unused  isKindOfClass:[NSPanel class]]) {
        path2 = [unused URL];
        basePath = [path2 path];
    }else if ([unused isKindOfClass:[NSString class]])
    {
        basePath=unused;
    }
    NSLog(@"%@",basePath);
    NSDirectoryEnumerator *filearry = [fileManger  enumeratorAtPath:basePath];
    for (NSString *file in filearry) {
        NSString *fullPath =[basePath stringByAppendingPathComponent:file];
        NSURL *musicURL;
        if ([[fullPath pathExtension] isEqualToString:@"mp3"] || [[fullPath pathExtension] isEqualToString:@"wmv"]) {
            NSString * musicType =[fullPath pathExtension];
            musicURL = [NSURL fileURLWithPath:fullPath];
            AVURLAsset *musicAsset = [AVURLAsset URLAssetWithURL:musicURL options:nil];
            Music *music = [[Music alloc] init];
            [music setMusicTime:[musicUtil getSongTime: musicAsset :music]];
            [music setMusicPathURL:fullPath];
            NSMutableDictionary *retDic = [[NSMutableDictionary alloc] init];
            
            //            AVURLAsset *mp3Asset = [AVURLAsset URLAssetWithURL:musicURL options:nil];
            
            //    NSLog(@"%@",mp3Asset);
            
            for (NSString *format in [musicAsset availableMetadataFormats]) {
                for (AVMetadataItem *metadataItem in [musicAsset metadataForFormat:format]) {
                    
                    if(metadataItem.commonKey)
                        [retDic setObject:metadataItem.value forKey:metadataItem.commonKey];
                    
                }
            }
            NSString * musicName = [NSString stringWithFormat:@"%@-%@",[retDic objectForKey:@"title"],[retDic objectForKey:@"artist"]];
            
            [music setMusicName:musicName];
            [music setMusicType:musicType];
            [music setMusicSinger:[retDic objectForKey:@"artist"]];
            [music setMusicAlbumName:[retDic objectForKey:@"albumName"]];
            //            [music setMusicCoverImage:[[retDic objectForKey:@"artwork"] objectForKey:@"data"]];
            int flag=0;
            if (arry.count>0 ) {
                for (Music *m in songList) {
                    if ([[m musicName] isEqualToString:[music musicName]]) {
                        flag=1;
                    }
                }
            }
            if (flag==0) {
                [songList addObject:music];
                
            }
            
        }
        
    }
    [self performSelectorOnMainThread:@selector(updateWithResults) withObject:nil waitUntilDone:YES];
    
    
}
//异步完成后更新主界面
-(void) updateWithResults
{
    //    NSLog(@"NSUserDefaults66 %@",[[NSUserDefaults standardUserDefaults] objectForKey:BNRRecentFileFolder]);
    [_songNumber setStringValue:[NSString stringWithFormat:@"(%ld)",[songList count]]];
    if (songList.count>0) {
        [musicDao clearTable];
        [musicDao insertMusic:songList];
    }
    
    [_musicTableView reloadData];
    [self.musicTableView setHidden:NO];
    [self.noSongsText setHidden:YES];
    [self.addSongsInFolderButton setHidden:YES];
    [_musicTableView setTarget:self];
    [_musicTableView setDoubleAction:@selector(playMusic)];
}


//列表配置

//- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
//{
//    Music * music = (Music *)songList[row];
//    return [music valueForKey:[ tableColumn identifier]];
//    
//}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
   
    return  [songList count];
}
- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row{
    return 50.0f;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSString *identifier = [tableColumn identifier];
    Music *tempMusic = (Music *) [songList objectAtIndex:row];
    if ([identifier isEqualToString:@"pusicCell"]) {
        // We pass us as the owner so we can setup target/actions into this main controller object
        PusicTableCellView *cellView = [tableView makeViewWithIdentifier:identifier owner:self];
        // Then setup properties on the cellView based on the column
        cellView.musicName.stringValue = tempMusic.musicName;
        NSImage *cover = [musicUtil getSongCoverImage:tempMusic];
        if (!cover) {
            cellView.imageView.image = [NSImage imageNamed:@"music_cover_default"];
        }else
        {
            cellView.imageView.image = cover;
        }
        
        cellView.musicArter.stringValue = tempMusic.musicSinger;
        cellView.musictime.stringValue = tempMusic.musicTime;
        return cellView;
    }else{
        return nil;
    }
}

//- (void)tableView:(NSTableView *)aTableView willDisplayCell:(id)aCell forTableColumn:(NSTableColumn *)TableColumn row:(NSInteger)rowIndex{
//    
//}

// 修改选中颜色方案一
// tableview 的 selection highlightstyle 需要是 regular
- (NSTableRowView*)tableView:(NSTableView*)tableView rowViewForRow:(NSInteger)row
{
    PusicTableRowView* rowView = [[PusicTableRowView alloc] initWithFrame:NSZeroRect];
    return rowView;
}

-(void) playMusic
{
    NSInteger row = [_musicTableView clickedRow];
    [self audioPlay:row];
    [self reflashUI];
    [self updatePlayProgress];
    
}

-(void) backgroundAddSong:(id) sender
{
    NSArray * arry = [songList copy];
    NSURL *path2;
    NSString *basePath ;
    if ([sender isKindOfClass:[NSPanel class]]) {
        path2 = [sender URL];
        basePath = [path2 path];
    }
    
    NSURL *musicURL;
    if ([[basePath pathExtension] isEqualToString:@"mp3"] || [[basePath pathExtension] isEqualToString:@"wmv"]) {
        NSString * musicType =[basePath pathExtension];
        musicURL = [NSURL fileURLWithPath:basePath];
        AVURLAsset *musicAsset = [AVURLAsset URLAssetWithURL:musicURL options:nil];
        Music *music = [[Music alloc] init];
        [music setMusicTime:[musicUtil getSongTime: musicAsset :music]];
        [music setMusicPathURL:basePath];
        NSMutableDictionary *retDic = [[NSMutableDictionary alloc] init];
        
        AVURLAsset *mp3Asset = [AVURLAsset URLAssetWithURL:musicURL options:nil];
        
        //    NSLog(@"%@",mp3Asset);
        
        for (NSString *format in [mp3Asset availableMetadataFormats]) {
            for (AVMetadataItem *metadataItem in [mp3Asset metadataForFormat:format]) {
                
                if(metadataItem.commonKey)
                    [retDic setObject:metadataItem.value forKey:metadataItem.commonKey];
                
            }
        }
        NSString * musicName = [NSString stringWithFormat:@"%@-%@",[retDic objectForKey:@"title"],[retDic objectForKey:@"artist"]];
        NSLog(@"%@",musicName);
        [music setMusicName:musicName];
        [music setMusicType:musicType];
        [music setMusicSinger:[retDic objectForKey:@"artist"]];
        [music setMusicAlbumName:[retDic objectForKey:@"albumName"]];
        //            [music setMusicCoverImage:[[retDic objectForKey:@"artwork"] objectForKey:@"data"]];
        int flag=0;
        if (arry.count>0 ) {
            for (Music *m in songList) {
                if ([[m musicName] isEqualToString:[music musicName]]) {
                    flag=1;
                }
            }
        }
        if (flag==0) {
            [songList addObject:music];
            
        }
        
        
        
    }
    [self performSelectorOnMainThread:@selector(updateWithResults) withObject:nil waitUntilDone:YES];
}
//文件操作

-(IBAction)deleteSong:(id)sender
{
    
    Music *music = [songList objectAtIndex:musicPlayingPosition];
    NSString *name = [music musicName];
    PusicAlert *alert = [PusicAlert alertWithTitle:@"删除警告!" MessageText:[NSString stringWithFormat:@"是否要删除歌曲：%@",name]   okButton:@"确定" cancelButton:@"取消" otherButton:nil imagePath:nil] ;
    
    NSInteger action = [alert RunModel];
    if(action == PusicAlertOkReturn)
    {
        [self clearSingleSongData:[alert isDelete]];
    }
    else if(action == PusicAlertCancelReturn )
    {
        NSLog(@"SYXAlertCancelButton clicked!");
    }
    
    
}


-(void) deleteFile:(NSArray *) list
{
    NSFileManager *manger = [NSFileManager defaultManager];
    if (list!=nil && list.count>0) {
        for(Music * music in list)
        {
            [manger removeItemAtPath:music.musicPathURL error:NULL];
        }
    }
    
}

-(void) clearAllData:(BOOL) state
{
    if(_player.isPlaying)
    {
        [_player pause];
        musicPlayingPosition = 0;
        
    }
    [musicDao clearTable ];
    if(state == YES)
    {
        [self deleteFile:songList];
    }
    [songList removeAllObjects];
    
    [_musicTableView reloadData];
}

-(void) clearSingleSongData:(BOOL) state
{
    if(_player.isPlaying)
    {
        [_player pause];
        musicPlayingPosition = 0;
        
    }
    [musicDao deleteMusic:[NSArray arrayWithObject:songList[[_musicTableView selectedColumn] ]]];
    
    
    if(state == YES)
    {
        [self deleteFile:[NSArray arrayWithObject:songList[[_musicTableView selectedColumn]] ]];
        [songList removeObjectAtIndex:[_musicTableView selectedColumn]];
    }
    [_musicTableView reloadData];
}



-(void) dealloc
{
}

@end
