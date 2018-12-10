//
//  ViewController.h
//  OneDriveDemo
//
//  Created by 圣光 on 2018/11/28.
//  Copyright © 2018年 圣光. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OneDriveSDK.h>
@interface ViewController : UIViewController
@property ODItem *currentItem;
@property(nonatomic,strong)ODClient * client;
@end

