//
//  LGCustomVideoCompositionInstruction.h
//  VideoBlend
//
//  Created by L了个G on 2017/12/20.
//  Copyright © 2017年 L了个G. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "LGVideoEditModel.h"
@interface LGCustomVideoCompositionInstruction :  NSObject <AVVideoCompositionInstruction>
@property CMPersistentTrackID sourceTrackID;
@property CMPersistentTrackID effectTrackID;

@property CMPersistentTrackID foregroundTrackID;
@property CMPersistentTrackID backgroundTrackID;
@property (assign,nonatomic)  TransitionType type;
- (id)initTransitionWithSourceTrackIDs:(NSArray*)sourceTrackIDs forTimeRange:(CMTimeRange)timeRange type:(TransitionType)type;
@end
