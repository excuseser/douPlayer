//
//  douPlayer.m
//  DeerGuide
//
//  Created by kan xu on 15/8/24.
//  Copyright (c) 2015年 kan xu. All rights reserved.
//

#import "douPlayer.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "DOUAudioStreamer.h"
#import "DOUAudioVisualizer.h"

static void *kStatusKVOKey = &kStatusKVOKey;
static void *kDurationKVOKey = &kDurationKVOKey;
static void *kBufferingRatioKVOKey = &kBufferingRatioKVOKey;

@implementation Track

@end

//这也是个单例
@implementation douPlayer{
    DOUAudioStreamer *_streamer;
    DOUAudioVisualizer *_audioVisualizer;
    NSTimer *_timer;
    
    BOOL needPlay;
}

- (instancetype)init{
    self = [super init];
    if(self) {
        _track = [[Track alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(audioSessionWasInterrupted:)
                                                      name:AVAudioSessionInterruptionNotification
                                                   object:nil];
    }
    return self;
}


#pragma mark -  DOUStreamer
- (void)_cancelStreamer {
    if (_streamer != nil) {
        [_streamer pause];
        [_streamer removeObserver:self forKeyPath:@"status"];
        [_streamer removeObserver:self forKeyPath:@"duration"];
        [_streamer removeObserver:self forKeyPath:@"bufferingRatio"];
        _streamer = nil;
    }
}

- (void)_resetStreamer {
    [self _cancelStreamer];
    _streamer = [DOUAudioStreamer streamerWithAudioFile:_track];
    [_streamer addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:kStatusKVOKey];
    [_streamer addObserver:self forKeyPath:@"duration" options:NSKeyValueObservingOptionNew context:kDurationKVOKey];
    [_streamer addObserver:self forKeyPath:@"bufferingRatio" options:NSKeyValueObservingOptionNew context:kBufferingRatioKVOKey];
    [_streamer play];
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(_timerAction:) userInfo:nil repeats:YES];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == kStatusKVOKey) {
        [self performSelector:@selector(_updateStatus)
                     onThread:[NSThread mainThread]
                   withObject:nil
                waitUntilDone:NO];
    }
    else if (context == kDurationKVOKey) {
        [self performSelector:@selector(_timerAction:)
                     onThread:[NSThread mainThread]
                   withObject:nil
                waitUntilDone:NO];
    }
    else if (context == kBufferingRatioKVOKey) {
        [self performSelector:@selector(_updateBufferingStatus)
                     onThread:[NSThread mainThread]
                   withObject:nil
                waitUntilDone:NO];
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)_updateStatus {
    if (self.statusBlock) {
        self.statusBlock(_streamer);
    }
}

- (void)_timerAction:(id)timer {
    if (self.durationBlock) {
        self.durationBlock(_streamer);
    }
}

- (void)_updateBufferingStatus {
    if (self.bufferingRatioBlock) {
        self.bufferingRatioBlock(_streamer);
    }
}

- (BOOL)isWorking{
    if (!_streamer) return NO;
    return (([_streamer status] == DOUAudioStreamerPaused) ||
            ([_streamer status] == DOUAudioStreamerPlaying) ||
            ([_streamer status] == DOUAudioStreamerBuffering));
}

- (BOOL)isPlaying{
    if (!_streamer) return NO;
    return !(([_streamer status] == DOUAudioStreamerPaused) || ([_streamer status] == DOUAudioStreamerIdle));
}

- (BOOL)isTruePlaying{
    if (!_streamer) return NO;
    return [_streamer status] == DOUAudioStreamerPlaying;
}

- (void)play{
    if ([_streamer status] == DOUAudioStreamerPaused) {
        [_streamer play];
        [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(_timerAction:) userInfo:nil repeats:YES];
    }
    else{
        [self _resetStreamer];
    }
}

-(void)pause{
    [_streamer pause];
}

- (void)stop{
    [_timer invalidate];
    [_streamer stop];
    [self _cancelStreamer];
}

- (float)currentTime{
    return [_streamer currentTime] / [_streamer duration];
}

- (void)setCurrentTime:(float)currentTime{
    [_streamer setCurrentTime:[_streamer duration] * currentTime];
}


- (void)shake{
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

- (void)audioSessionWasInterrupted:(NSNotification *)notification
{
    if ([notification.userInfo count] == 0){
        return;
    }
    if (AVAudioSessionInterruptionTypeBegan == [notification.userInfo[AVAudioSessionInterruptionTypeKey] intValue]) {
        if (self.isTruePlaying) {
            [self pause];
            needPlay =YES;
        }
    }
    
    if (AVAudioSessionInterruptionTypeEnded == [notification.userInfo[AVAudioSessionInterruptionTypeKey] intValue]) {
        if (needPlay) {
            [self play];
            needPlay =NO;
        }
    }
}

@end
