//
//  ViewController.m
//  douPlayer
//
//  Created by kan xu on 15/11/11.
//  Copyright © 2015年 kan xu. All rights reserved.
//

#import "ViewController.h"
#import "douPlayer.h"

@interface ViewController ()

@property (nonatomic, strong) IBOutlet UIStackView *playerView;
@property (nonatomic, strong) IBOutlet UIButton *playBtn;
@property (nonatomic, strong) IBOutlet UISlider *playSlider;
@property (nonatomic, strong) IBOutlet UILabel *playInfoLbl;
@property (nonatomic, strong) IBOutlet UILabel *playNameLbl;

@end

@implementation ViewController{
    douPlayer *Player;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    Player = [[douPlayer alloc] init];
    _playerView.hidden = YES;
    
    _playInfoLbl.text = @"";
    
    [self PlayerControl];
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)showLocalMp3:(id)sender{
    _playerView.hidden = NO;
    
    [Player stop];
    Player.track.title = @"Local Music";
    NSString *mp3 = [[NSBundle mainBundle] pathForResource:@"5cm" ofType:@"mp3" inDirectory:nil];
    Player.track.audioFileURL = [NSURL fileURLWithPath:mp3];
    _playNameLbl.text = @"5cm";
    [Player play];
    
}

-(IBAction)showRemoteMp3:(id)sender{
    _playerView.hidden = NO;
    
    [Player stop];
    Player.track.title = @"net Music";
    NSString *mp3name = @"http://down1.cndzq.com/demo/yamaha_p115/voicedemo/grandpiano_demo_p115.mp3";    
    if ( ([mp3name hasPrefix:@"http://"]) && !([mp3name hasPrefix:@"https://"]) ) {
        Player.track.audioFileURL = [NSURL URLWithString:mp3name];
    }
    _playNameLbl.text = @"Demo";
    [Player play];
}

-(IBAction)playSliderProgress:(id)sender{
    Player.currentTime = _playSlider.value;
}

- (IBAction)playPause:(id)sender{
    if (Player.isPlaying) {
        [Player pause];
    }
    else{
        [Player play];
    }
}

-(IBAction)replay:(id)sender{
    [Player stop];
    [Player play];
}

- (IBAction)stopPlay:(id)sender{
    _playSlider.value = 0;
    [Player stop];
    _playInfoLbl.text = @"";
}

- (void)PlayerControl{
    __weak typeof(self) weakSelf = self;
    __weak typeof(douPlayer *) weakDouPLayer = Player;
    
    if ([Player isPlaying]) {
        [_playBtn setTitle:@"Pause" forState:UIControlStateNormal];
    }
    else{
        [_playBtn setTitle:@"Play" forState:UIControlStateNormal];
    }
    
    [Player setStatusBlock:^(DOUAudioStreamer *streamer) {
        switch ([streamer status]) {
            case DOUAudioStreamerPlaying:
                [weakSelf.playBtn setTitle:@"Pause" forState:UIControlStateNormal];
                weakSelf.playInfoLbl.text = @"Playing";
                break;
                
            case DOUAudioStreamerPaused:
                [weakSelf.playBtn setTitle:@"Play" forState:UIControlStateNormal];
                weakSelf.playInfoLbl.text = @"Pause";
                break;
                
            case DOUAudioStreamerIdle:
                [weakSelf.playBtn setTitle:@"Play" forState:UIControlStateNormal];
                [weakSelf.playSlider setValue:0.0f animated:NO];
                [weakDouPLayer stop];
                weakSelf.playInfoLbl.text = @"Idle";
                break;
                
            case DOUAudioStreamerFinished:
                [weakSelf.playBtn setTitle:@"Play" forState:UIControlStateNormal];
                [weakSelf.playSlider setValue:0.0f animated:NO];
                [weakDouPLayer stop];
                weakSelf.playInfoLbl.text = @"Play end";
                break;
                
            case DOUAudioStreamerBuffering:
                weakSelf.playInfoLbl.text = @"Buffering";
                break;
                
            case DOUAudioStreamerError:
                [weakSelf.playBtn setTitle:@"Play" forState:UIControlStateNormal];
                [weakSelf.playSlider setValue:0.0f animated:NO];
                [weakDouPLayer stop];
                weakSelf.playInfoLbl.text = @"net error";
                break;
        }
    }];
    
    [Player setDurationBlock:^(DOUAudioStreamer *streamer) {
        if ([streamer duration] == 0.0) {
            [weakSelf.playSlider setValue:0.0f animated:NO];
        }
        else {
            [weakSelf.playSlider  setValue:[streamer currentTime] / [streamer duration] animated:YES];
        }
    }];
}

@end
