//
//  ViewController.h
//  Pusic
//
//  Created by peter on 15/10/6.
//  Copyright © 2015年 peter. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MusicDao.h"
#import "PusicUserDefaults.h"
#import "PusicRHStatusItemView.h"
#import "PusicPopOverViewDelagate.h"
#import "EZAudio.h"
#import "Pusic Utils/musicUtil.h"
#import "NPView.h"

NSString * const PusicViewControllerPlayOne = @"PusicViewControllerPlayOne" ;
NSString * const PusicViewControllerPlayList =@"PusicViewControllerPlayList";
NSString * const PusicViewControllerProRadom=@"PusicViewControllerProRadom" ;
@interface PusicMainViewController : NSViewController <NSApplicationDelegate,NSUserNotificationCenterDelegate,NSOpenSavePanelDelegate,EZAudioPlayerDelegate>
{
    NSMutableArray * songList;
    NSInteger musicPlayingPosition;
    NSTimer *currentTimer;
    MusicDao * musicDao;
    BOOL isCirculate ;
    BOOL isRandom;
    BOOL isList;
    PusicPopOverViewDelagate * popOverDelagate;
    PusicUserDefaults *defaults;
    Music * currentMusic;
}
@property (strong) IBOutlet NPView *upView;
@property (strong) IBOutlet NPView *downView;
@property (strong) IBOutlet NSTextField *musicType;


@property (weak) IBOutlet NSSlider *volumeSlider;
@property (weak) IBOutlet NSButton *nextButton;
@property (weak) IBOutlet NSButton *playButton;
@property (strong) IBOutlet NSButton *proButton;
@property (weak) IBOutlet NSButton *deleteSong;
@property (weak) IBOutlet NSButton *addSong;
@property (weak) IBOutlet NSButton *makeUnarrylist;
@property (weak) IBOutlet NSButton *clearButton;

@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSTextField *musicTimeLabel;
@property (weak) IBOutlet NSTextField *songNumber;
@property (strong) IBOutlet NSTextField *musicFormate;
@property (strong) IBOutlet NSTextField *musicRate;
@property (weak) IBOutlet NSButton *addSongsInFolderButton;
@property (strong) IBOutlet NSTextField *musicCode;

@property (strong) IBOutlet NSTextField *musicSonger;
@property (strong) IBOutlet NSTextField *musicName;
@property (strong) IBOutlet NSTextField *noSongsText;



@property (weak) IBOutlet NSTableView *musicTableView;
@property (strong) IBOutlet NSButton *shuffleButton;
@property (strong) IBOutlet NSButton *repeatButton;
@property (strong) IBOutlet NSButton *songListButton;

@property PusicRHStatusItemView *statusView;
@property (nonatomic, strong) EZAudioFile *audioFile;
@property (nonatomic, strong) EZAudioPlayer *player;
@property NSStatusItem *statusItem;



- (IBAction)buttonPlay:(id)sender;
- (IBAction)next:(id)sender;
- (IBAction)pro:(id)sender;
- (IBAction)addFolder:(id)sender;
- (IBAction)clear:(id)sender;
- (IBAction)disSort:(id)sender;
- (IBAction)addSong:(id)sender;
- (IBAction)deleteSong:(id)sender;
- (IBAction)adjustVolume:(id)sender;
- (IBAction)playOneSong:(id)sender;

- (IBAction)shufflePlay:(id)sender;
- (IBAction)listPlay:(id)sender;
- (IBAction)repeatPlay:(id)sender;

//-(void) playMusic;
-(void) play:(NSInteger) position;

@end

