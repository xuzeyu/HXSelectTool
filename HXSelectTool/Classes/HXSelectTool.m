//
//  HXSelectTool.m
//  LotteryManager
//
//  Created by Harvey on 2020/11/11.
//  Copyright © 2020 sinodata. All rights reserved.
//

#import "HXSelectTool.h"
#import <HXPhotoPicker/HXPhotoPicker.h>

@interface HXSelectTool ()
@property (nonatomic, strong) HXPhotoManager *photoManager;
@end

@implementation HXSelectTool

+ (HXSelectTool *)shareInstance {
    static HXSelectTool *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[HXSelectTool alloc] init];
    });
    return instance;
}

+ (void)choosePhotoInVC:(UIViewController *)vc photoCount:(NSInteger)photoCount complete:(SelectedPhotoBackBlock)complete {
    HXPhotoManager *photoManager = [HXSelectTool shareInstance].photoManager;
    photoManager.configuration.maxNum = photoCount;
    photoManager.configuration.photoMaxNum = photoCount;
    
    NSArray *items = @[@"使用相机拍摄",@"从相册选择"];
    
    [HXPhotoBottomSelectView showSelectViewWithTitles:items selectCompletion:^(NSInteger index, HXPhotoBottomViewModel * _Nonnull model) {
        if (index == 0) {
            [self openCameraInVC:vc photoCount:photoCount complete:complete];
        }else {
            [self openLibraryInVC:vc photoCount:photoCount complete:complete];
        }
    } cancelClick:nil];
}

//打开相机
+ (void)openCameraInVC:(UIViewController *)vc photoCount:(NSInteger)photoCount complete:(SelectedPhotoBackBlock)complete {
    [self openCameraInVC:vc photoCount:photoCount type:HXPhotoManagerSelectedTypePhoto complete:complete];
}

+ (void)openCameraInVC:(UIViewController *)vc photoCount:(NSInteger)photoCount type:(HXPhotoManagerSelectedType)type complete:(SelectedPhotoBackBlock)complete {
    HXPhotoManager *photoManager = [HXSelectTool shareInstance].photoManager;
    photoManager.configuration.maxNum = photoCount;
    photoManager.configuration.photoMaxNum = photoCount;
    photoManager.type = type;
    
    [vc hx_presentCustomCameraViewControllerWithManager:[HXSelectTool shareInstance].photoManager
                                                     done:^(HXPhotoModel *model, HXCustomCameraViewController *viewController) {
        NSArray *array = @[model.previewPhoto];
        if (complete) {
            complete(array, @[model], viewController.manager);
        }
        [photoManager clearSelectedList];
    } cancel:nil];
}

//打开相册
+ (void)openLibraryInVC:(UIViewController *)vc photoCount:(NSInteger)photoCount complete:(SelectedPhotoBackBlock)complete {
    HXPhotoManager *photoManager = [HXSelectTool shareInstance].photoManager;
    photoManager.configuration.maxNum = photoCount;
    photoManager.configuration.photoMaxNum = photoCount;
    
    [vc hx_presentSelectPhotoControllerWithManager:[HXSelectTool shareInstance].photoManager
                                             didDone:^(NSArray<HXPhotoModel *> *allList, NSArray<HXPhotoModel *> *photoList, NSArray<HXPhotoModel *> *videoList, BOOL isOriginal, UIViewController *viewController, HXPhotoManager *manager) {
        
        NSArray *array = [HXSelectTool getHXSelectImgs:photoList];
        if (complete) {
            complete(array, allList, manager);
        }
        [photoManager clearSelectedList];
    } cancel:nil];
}

#pragma mark - Tool
+ (NSArray *)getHXSelectImgs:(NSArray *)photos
{
    NSMutableArray *array = @[].mutableCopy;
    for (HXPhotoModel *model in photos) {
        
        if (model.networkPhotoUrl) {
            //网络图片
            [model requestPreviewImageWithSize:PHImageManagerMaximumSize
                            startRequestICloud:nil
                               progressHandler:nil
                                       success:^(UIImage * _Nullable image, HXPhotoModel * _Nullable model, NSDictionary * _Nullable info) {
                [array addObject:image];
                
            } failed:^(NSDictionary * _Nullable info, HXPhotoModel * _Nullable model) {
                NSLog(@"下载网络图片失败--%@",info);
            }];
            continue;
        }
        
        if (model.previewPhoto) {
            
            [array addObject:model.previewPhoto];
            continue;
        }
        
        if (model.thumbPhoto) {
            
            [array addObject:model.thumbPhoto];
            continue;
        }
        
        if (model.subType == HXPhotoModelMediaSubTypePhoto) {
            //被编辑过的图片
            UIImage *image = model.photoEdit.editPreviewImage;
            [array addObject:image];
            continue;
        }
    }
    return array;
}

#pragma mark - Attribute
- (HXPhotoManager *)photoManager
{
    if (!_photoManager) {
        _photoManager = [HXPhotoManager managerWithType:HXPhotoManagerSelectedTypePhoto];
        _photoManager.configuration.selectTogether = NO;
        _photoManager.configuration.openCamera = NO;
        _photoManager.configuration.photoCanEdit = NO;
        _photoManager.configuration.showBottomPhotoDetail = NO;
        _photoManager.configuration.requestImageAfterFinishingSelection = YES;
    }
    return _photoManager;
}


@end
