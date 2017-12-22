//
//  LGPassthroughVideoCompositionInstruction.h
//  视频转场
//
//  Created by L了个G on 2017/12/22.
//  Copyright © 2017年 L了个G. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "LGVideoEditModel.h"
@interface LGPassthroughVideoCompositionInstruction : NSObject<AVVideoCompositionInstruction>
- (id)initPassThroughTrackID:(CMPersistentTrackID)passthroughTrackID forTimeRange:(CMTimeRange)timeRange;
@end
