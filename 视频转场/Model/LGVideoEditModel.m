//
//  LGVideoEditModel.m
//  VideoBlend
//
//  Created by L了个G on 2017/12/20.
//  Copyright © 2017年 L了个G. All rights reserved.
//

#import "LGVideoEditModel.h"

@implementation LGVideoEditModel
static NSString *const AVAssetTracksKey = @"tracks";
static NSString *const AVAssetDurationKey = @"duration";
static NSString *const AVAssetCommonMetadataKey = @"commonMetadata";
+(void)loadResoureWithURL:(NSString *)URL completion:(CompletionBlock)completion
{
    __block LGVideoEditModel *model = [LGVideoEditModel new];
    NSDictionary *options = @{AVURLAssetPreferPreciseDurationAndTimingKey:@YES};
    model.asset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:URL] options:options];
    NSArray *keys = @[AVAssetTracksKey,AVAssetDurationKey,AVAssetCommonMetadataKey];
    [model.asset loadValuesAsynchronouslyForKeys:keys completionHandler:^{
        NSError *error ;
        AVKeyValueStatus tracksStatus = [model.asset statusOfValueForKey:AVAssetTracksKey error:&error];
        AVKeyValueStatus durationStatus = [model.asset statusOfValueForKey:AVAssetDurationKey error:&error];
        if((tracksStatus == AVKeyValueStatusLoaded)&&(durationStatus == AVKeyValueStatusLoaded)){
            AVAssetTrack *videoTrack = [[model.asset tracksWithMediaType:AVMediaTypeVideo] firstObject];
            model.clipTimeRange = videoTrack.timeRange;
            !completion?:completion(model);
        }
    }];
}
@end
