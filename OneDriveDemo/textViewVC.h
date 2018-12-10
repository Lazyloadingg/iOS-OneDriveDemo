//
//  textView.h
//  OneDriveDemo
//
//  Created by 圣光 on 2018/12/10.
//  Copyright © 2018年 圣光. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OneDriveSDK.h>
NS_ASSUME_NONNULL_BEGIN

@interface textViewVC : UIViewController
@property(nonatomic,strong)NSString * filePath;
@property ODItem *item;

@property ODItem *parentItem;

@property ODClient *client;
@end

NS_ASSUME_NONNULL_END
