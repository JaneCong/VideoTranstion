//
//  AVPlayerItem+Additions.h
//  VideoBlend
//
//  Created by L了个G on 2017/12/20.
//  Copyright © 2017年 L了个G. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

@interface AVPlayerItem (Additions)
@property (strong,nonatomic)AVSynchronizedLayer *syncLayer;

- (BOOL)hasValidDuration;
- (void)muteAudioTracks:(BOOL)vaule;
@end
