//
//  AVPlayerItem+Additions.m
//  VideoBlend
//
//  Created by L了个G on 2017/12/20.
//  Copyright © 2017年 L了个G. All rights reserved.
//

#import "AVPlayerItem+Additions.h"
#import <objc/runtime.h>
static id MakerSynchronizedLayerKey;
@implementation AVPlayerItem (Additions)
- (AVSynchronizedLayer *)syncLayer{
    return objc_getAssociatedObject(self, &MakerSynchronizedLayerKey);
}
- (void)setSyncLayer:(AVSynchronizedLayer *)syncLayer{
    objc_setAssociatedObject(self, &MakerSynchronizedLayerKey, syncLayer, OBJC_ASSOCIATION_RETAIN);
}
- (BOOL)hasValidDuration{
    return self.status == AVPlayerItemStatusReadyToPlay&&CMTIME_IS_INVALID(self.duration);
}
- (void)muteAudioTracks:(BOOL)vaule{
    for (AVPlayerItemTrack *track in self.tracks) {
        if([track.assetTrack.mediaType isEqualToString:AVMediaTypeAudio]){
            track.enabled = !vaule;
        }
    }
}
@end
