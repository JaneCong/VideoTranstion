//
//  LGPassthroughVideoCompositionInstruction.m
//  视频转场
//
//  Created by L了个G on 2017/12/22.
//  Copyright © 2017年 L了个G. All rights reserved.
//

#import "LGPassthroughVideoCompositionInstruction.h"

@implementation LGPassthroughVideoCompositionInstruction
@synthesize timeRange = _timeRange;
@synthesize enablePostProcessing = _enablePostProcessing;
@synthesize containsTweening = _containsTweening;
@synthesize requiredSourceTrackIDs = _requiredSourceTrackIDs;
@synthesize passthroughTrackID = _passthroughTrackID;

- (id)initPassThroughTrackID:(CMPersistentTrackID)passthroughTrackID forTimeRange:(CMTimeRange)timeRange
{
    self = [super init];
    if (self) {
        _passthroughTrackID = passthroughTrackID;
        _requiredSourceTrackIDs = nil;
        _timeRange = timeRange;
        _containsTweening = NO;
        _enablePostProcessing = YES;
    }
    
    return self;
}
@end
