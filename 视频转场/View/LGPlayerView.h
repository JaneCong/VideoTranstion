//
//  LGPlayerView.h
//  VideoBlend
//
//  Created by L了个G on 2017/12/20.
//  Copyright © 2017年 L了个G. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "AVPlayerItem+Additions.h"
@interface LGPlayerView : UIView
+ (id)player:(CGRect)frame;
- (void)play;
- (void)pause;
- (void)seekToTime:(CMTime)time;
- (void)add30FpsTimeObserverForInterval:(void(^)(CMTime time))callBack;
- (BOOL)isPlaying;
- (CALayer *)attachPlayItem:(AVPlayerItem *)item;
- (void)attachSyncLayer:(AVSynchronizedLayer *)layer bounds:(CGRect)bounds;
@end
