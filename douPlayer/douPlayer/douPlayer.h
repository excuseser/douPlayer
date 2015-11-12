//
//  douPlayer.h
//  DeerGuide
//
//  Created by kan xu on 15/8/24.
//  Copyright (c) 2015年 kan xu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DOUAudioFile.h"
#import "DOUAudioStreamer.h"

@interface Track : NSObject <DOUAudioFile>
//这里可以
@property (nonatomic, strong) NSString *artist;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSURL *audioFileURL;

@end

@interface douPlayer : NSObject

@property (nonatomic, strong) Track *track;

@property (nonatomic) float currentTime;

- (BOOL)isWorking;
- (BOOL)isPlaying;
- (BOOL)isTruePlaying;
- (void)play;
- (void)pause;
- (void)stop;

- (void)shake;

@property(nonatomic,copy) void(^statusBlock)(DOUAudioStreamer *streamer);
@property(nonatomic,copy) void(^durationBlock)(DOUAudioStreamer *streamer);
@property(nonatomic,copy) void(^bufferingRatioBlock)(DOUAudioStreamer *streamer);

@end
