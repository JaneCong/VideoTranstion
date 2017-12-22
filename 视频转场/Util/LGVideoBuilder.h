//
//  LGVideoBuilder.h
//  VideoBlend
//
//  Created by L了个G on 2017/12/20.
//  Copyright © 2017年 L了个G. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "LGVideoEditModel.h"
@interface LGVideoBuilder : NSObject

+ (instancetype)sharedBuilder;

- (AVPlayerItem *)buildPlayerItem;


-(void)buildVideoWithModels:(NSArray <LGVideoEditModel *> *)models;

@end
