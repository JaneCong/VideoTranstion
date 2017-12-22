//
//  LGVideoEditModel.h
//  VideoBlend
//
//  Created by L了个G on 2017/12/20.
//  Copyright © 2017年 L了个G. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
typedef NS_ENUM(NSUInteger, TransitionType) {
    RenderTransisionTypeNone = 0,
    RenderTransisionTypeDissolve,
    RenderTransisionTypePinwheel,// 转轮
    //RenderTransisionTypeSimpleFlip,
    RenderTransisionTypeWind,
    //RenderTransisionTypeFold,
    //RenderTransisionTypeStarWipe,
    //RenderTransisionTypeFlyeye,
    RenderTransisionTypeRipple,
    RenderTransisionTypePixelize,
    RenderTransisionTypePowDistortion,
};
@class LGVideoEditModel;
typedef void(^CompletionBlock)(LGVideoEditModel *model);
@interface LGVideoEditModel : NSObject
@property (nonatomic) AVURLAsset  *asset;
@property (nonatomic) CMTimeRange clipTimeRange;
@property (nonatomic) TransitionType transitionType;
+(void)loadResoureWithURL:(NSString *)URL completion:(CompletionBlock)completion;
@end
