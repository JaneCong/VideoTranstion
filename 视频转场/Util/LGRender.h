//
//  LGRender.h
//  VideoBlend
//
//  Created by L了个G on 2017/12/20.
//  Copyright © 2017年 L了个G. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "LGVideoEditModel.h"
@interface LGRender : NSObject
+ (instancetype)sharedRender;

- (void)renderPixelBuffer:(CVPixelBufferRef)destinationPixelBuffer usingForegroundSourceBuffer:(CVPixelBufferRef)foregroundPixelBuffer andBackgroundSourceBuffer:(CVPixelBufferRef)backgroundPixelBuffer forTweenFactor:(float)tween type:(TransitionType)type;


@end
