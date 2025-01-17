//
//  HXSelectTool.h
//  LotteryManager
//
//  Created by Harvey on 2020/11/11.
//  Copyright © 2020 sinodata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HXPhotoPicker.h"

NS_ASSUME_NONNULL_BEGIN
typedef void(^SelectedPhotoBackBlock)(NSArray <UIImage *>*photos, NSArray <HXPhotoModel *>*models, HXPhotoManager *photoManager);

@interface HXSelectTool : NSObject

+ (NSArray *)getHXSelectImgs:(NSArray *)photos;
+ (void)choosePhotoInVC:(UIViewController *)vc photoCount:(NSInteger)photoCount complete:(SelectedPhotoBackBlock)complete;
+ (void)openCameraInVC:(UIViewController *)vc photoCount:(NSInteger)photoCount complete:(SelectedPhotoBackBlock)complete;
+ (void)openCameraInVC:(UIViewController *)vc photoCount:(NSInteger)photoCount type:(HXPhotoManagerSelectedType)type complete:(SelectedPhotoBackBlock)complete ;
+ (void)openLibraryInVC:(UIViewController *)vc photoCount:(NSInteger)photoCount complete:(SelectedPhotoBackBlock)complete;

@end

NS_ASSUME_NONNULL_END
