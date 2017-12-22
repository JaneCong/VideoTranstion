//
//  LGVideoBuilder.m
//  VideoBlend
//
//  Created by L了个G on 2017/12/20.
//  Copyright © 2017年 L了个G. All rights reserved.
//

#import "LGVideoBuilder.h"
#import "LGCustomVideoCompositionInstruction.h"
#import "LGPassthroughVideoCompositionInstruction.h"
#import "LGCustomVideoCompositor.h"
static const CGFloat TransitionTime = 2.0;
@interface LGVideoBuilder()
@property (nonatomic, strong) AVMutableComposition *composition;
@property (nonatomic, strong) AVMutableVideoComposition *videoComposition;
@end
@implementation LGVideoBuilder
+ (instancetype)sharedBuilder {
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [self new];
    });
    return instance;
}

-(void)buildVideoWithModels:(NSArray *)models
{
    
    self.composition = [AVMutableComposition composition];
    self.videoComposition = [AVMutableVideoComposition videoComposition];
    self.videoComposition.customVideoCompositorClass = [LGCustomVideoCompositor class];
    
    CMTime nextClipStartTime = kCMTimeZero;
    NSUInteger count = [models count];
    NSInteger i;
    AVMutableCompositionTrack *compositionVideoTracks[2];
    
    compositionVideoTracks[0] = [self.composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    compositionVideoTracks[1] = [self.composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];

    CMTimeRange *passThroughTimeRanges = alloca(sizeof(CMTimeRange) * count);
    CMTimeRange *transitionTimeRanges = alloca(sizeof(CMTimeRange) * count);
    CMTime transitonDuration = CMTimeMake(TransitionTime * 1000, 1000);
    for (i = 0; i < count; i++) {
        NSInteger alternatingIndex = i % 2;
        LGVideoEditModel *model = models[i];

        AVAssetTrack *clipVideoTrack = [[model.asset tracksWithMediaType:AVMediaTypeVideo] firstObject];

        [compositionVideoTracks[alternatingIndex] insertTimeRange:model.clipTimeRange ofTrack:clipVideoTrack atTime:nextClipStartTime error:nil];
        
        
        
        passThroughTimeRanges[i] = CMTimeRangeMake(nextClipStartTime,model.clipTimeRange.duration);
        if (i > 0) {
            passThroughTimeRanges[i].start = CMTimeAdd(passThroughTimeRanges[i].start,transitonDuration);
            passThroughTimeRanges[i].duration = CMTimeSubtract(passThroughTimeRanges[i].duration, transitonDuration);
        }
        if (i+1 < count) {
            passThroughTimeRanges[i].duration = CMTimeSubtract(passThroughTimeRanges[i].duration, transitonDuration);
        }
        
        nextClipStartTime = CMTimeAdd(nextClipStartTime, model.clipTimeRange.duration);
        nextClipStartTime = CMTimeSubtract(nextClipStartTime, transitonDuration);
        
        // Remember the time range for the transition to the next item.
        if (i+1 < count) {
            transitionTimeRanges[i] = CMTimeRangeMake(nextClipStartTime, transitonDuration);
        }
    }
    
    NSMutableArray *instructions = [NSMutableArray array];
    for (i = 0; i < count; i++) {
        LGVideoEditModel *model = models[i];
        NSInteger index = i % 2;
        if (self.videoComposition.customVideoCompositorClass) {
            
            LGPassthroughVideoCompositionInstruction *instruction = [[LGPassthroughVideoCompositionInstruction alloc] initPassThroughTrackID:compositionVideoTracks[index].trackID forTimeRange:passThroughTimeRanges[i]];
            [instructions addObject:instruction];
                
                
                if (i+1 < count) {
                    if (self.videoComposition.customVideoCompositorClass) {
                        
                        LGCustomVideoCompositionInstruction *instruction = [[LGCustomVideoCompositionInstruction alloc] initTransitionWithSourceTrackIDs:@[[NSNumber numberWithInt:compositionVideoTracks[0].trackID], [NSNumber numberWithInt:compositionVideoTracks[1].trackID]] forTimeRange:transitionTimeRanges[i] type:(TransitionType)model.transitionType];
                        
                        // First track -> Foreground track while compositing
                        instruction.foregroundTrackID = compositionVideoTracks[index].trackID;
                        // Second track -> Background track while compositing
                        instruction.backgroundTrackID = compositionVideoTracks[1-index].trackID;
                        
                        [instructions addObject:instruction];

                    }
                }
            
        }
    }
    
        self.videoComposition.renderSize = CGSizeMake(540, 960);
        self.videoComposition.frameDuration = CMTimeMake(1, 15);
        self.videoComposition.instructions = instructions;
    
}

//-(void)buildVideoWithModel:(LGVideoEditModel *)model
//{
//    self.composition = [AVMutableComposition composition];
//    self.videoComposition = [AVMutableVideoComposition videoComposition];
//    self.videoComposition.customVideoCompositorClass = [LGCustomVideoCompositor class];
//    
//    AVAssetTrack *track0 = [[model.asset tracksWithMediaType:AVMediaTypeVideo] firstObject];
//    
//    AVMutableCompositionTrack *firstTrack = [self.composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
//    
//    [firstTrack insertTimeRange:track0.timeRange ofTrack:track0 atTime:kCMTimeZero error:nil];
//    
//    
//    LGCustomVideoCompositionInstruction *videoInstruction = [[LGCustomVideoCompositionInstruction alloc] initSourceTrackID:firstTrack.trackID forTimeRange:track0.timeRange type:model.filterType];
//    
//    self.videoComposition.renderSize = track0.naturalSize;
//    self.videoComposition.frameDuration = CMTimeMake(1, 15);
//    self.videoComposition.instructions = @[videoInstruction];
//}



-(AVPlayerItem *)buildPlayerItem
{
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:self.composition];
    playerItem.videoComposition = self.videoComposition;
    return playerItem;
    
}

@end
