//
//  LGPlayerView.m
//  VideoBlend
//
//  Created by L了个G on 2017/12/20.
//  Copyright © 2017年 L了个G. All rights reserved.
//

#import "LGPlayerView.h"

@interface LGPlayerView()
@property (nonatomic) BOOL seeking;
@property (nonatomic) AVPlayer *player;
@property (nonatomic) UIView *overlayView;
@property (nonatomic) AVPlayerLayer *playerLayer;
@property (weak,nonatomic) id periodicTimeObserver;
@end

@implementation LGPlayerView
+(id)player:(CGRect)frame{
    return [[self alloc]initWithFrame:frame];
}

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        self.backgroundColor = [UIColor clearColor];
        
    }
    return self;
}

#pragma - mark Public Method

-(void)play{
    NSLog(@"playing =======");
    if(self.player){
        [self.player play];
    }
}

-(void)pause{
    if(self.player){
        if(self.periodicTimeObserver){
            [self.player removeTimeObserver:self.periodicTimeObserver];
            self.periodicTimeObserver = nil;
        }
        [self.player pause];
    }
}

-(void)seekToTime:(CMTime)time{
    if(self.player){
        [self pause];
        if(!self.seeking){
            self.seeking = YES;
            [self.player seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
                self.seeking = NO;
            }];
        }
    }
}

-(void)add30FpsTimeObserverForInterval:(void (^)(CMTime))callBack{
    if(self.player){
        [self.player removeTimeObserver:self.periodicTimeObserver];
        self.periodicTimeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(10, 300) queue:NULL usingBlock:^(CMTime time) {
            if(callBack)
                callBack(time);
        }];
    }
}

-(BOOL)isPlaying{
    BOOL result;
    result = self.player && self.player.rate != 0.0;
    return result;
}

-(CALayer *)attachPlayItem:(AVPlayerItem *)item{
    if(self.player){
        [self pause];
        [self.player replaceCurrentItemWithPlayerItem:item];
    }else{
        self.player = [[AVPlayer alloc] initWithPlayerItem:item];
        self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        self.playerLayer.frame = self.bounds;
        self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
        [self.layer addSublayer:self.playerLayer];
        
    }
    return self.playerLayer;
}

- (void)attachSyncLayer:(AVSynchronizedLayer *)syncLayer bounds:(CGRect)bounds{
    if(self.overlayView){
        [self.overlayView removeFromSuperview];
    }
    self.overlayView = [[UIView alloc]initWithFrame:CGRectZero];
    syncLayer.bounds = bounds;
    CGFloat scale = fminf(self.bounds.size.width / bounds.size.width, self.bounds.size.height /bounds.size.height);
    CGRect videoRect = AVMakeRectWithAspectRatioInsideRect(bounds.size, self.bounds);
    self.overlayView.center = CGPointMake( CGRectGetMidX(videoRect), CGRectGetMidY(videoRect));
    self.overlayView.transform = CGAffineTransformMakeScale(scale, scale);
    self.overlayView.backgroundColor = [UIColor redColor];
    [self addSubview:self.overlayView];
    [self.overlayView.layer addSublayer:syncLayer];
}
@end
