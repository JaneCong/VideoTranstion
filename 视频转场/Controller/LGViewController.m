//
//  LGViewController.m
//  视频滤镜
//
//  Created by L了个G on 2017/12/21.
//  Copyright © 2017年 L了个G. All rights reserved.
//

#import "LGViewController.h"
#import "LGPlayerView.h"
#import "LGVideoBuilder.h"
@interface LGViewController ()
@property (weak, nonatomic) IBOutlet LGPlayerView *playerView1;
@property (nonatomic) NSMutableArray <LGVideoEditModel *>*videoModels;
@end

@implementation LGViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    self.videoModels = [NSMutableArray array];
    
    [LGVideoEditModel loadResoureWithURL:[[NSBundle mainBundle] pathForResource:@"1" ofType:@"mp4"] completion:^(LGVideoEditModel *model) {
        [self.videoModels addObject:model];
    }];
    [LGVideoEditModel loadResoureWithURL:[[NSBundle mainBundle] pathForResource:@"2" ofType:@"mp4"] completion:^(LGVideoEditModel *model) {
        [self.videoModels addObject:model];
    }];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"提示" message:@"请选择滤镜类型" preferredStyle:UIAlertControllerStyleActionSheet];

    NSArray *transitions = @[@"Dissolve",@"Pinwheel",@"Wind",@"Ripple",@"Pixelize",@"Distortion"];
    [transitions enumerateObjectsUsingBlock:^(NSString *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:obj style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self.videoModels.firstObject.transitionType = idx + 1;
            [self play];
        }];
        [controller addAction:action];
    }];


    [self presentViewController:controller animated:YES completion:nil];
}



- (void)play{
    [[LGVideoBuilder sharedBuilder] buildVideoWithModels:self.videoModels];
     [self preparePlayBackWithPreview:self.playerView1 PlayerItem:[[LGVideoBuilder sharedBuilder] buildPlayerItem]];
}

- (void)preparePlayBackWithPreview:(LGPlayerView *)preview PlayerItem:(AVPlayerItem *)item{
    [preview attachPlayItem:item];
    [preview attachSyncLayer:item.syncLayer bounds:CGRectMake(0, 0,540, 960)];
    [preview play];
}



@end
