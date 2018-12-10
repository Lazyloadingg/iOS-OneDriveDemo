//
//  textView.m
//  OneDriveDemo
//
//  Created by 圣光 on 2018/12/10.
//  Copyright © 2018年 圣光. All rights reserved.
//

#import "textViewVC.h"

@interface textViewVC ()
@property(nonatomic,strong)UITextView * textView;
@end

@implementation textViewVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadDefaultsSetting];
    [self initSubViews];
    
    [self.textView setText:[NSString stringWithContentsOfURL:[NSURL fileURLWithPath:self.filePath] encoding:NSUTF8StringEncoding error:nil]];
    
}


#pragma mark >_<! 👉🏻 🐷Life cycle🐷
#pragma mark >_<! 👉🏻 🐷System Delegate🐷
#pragma mark >_<! 👉🏻 🐷Custom Delegate🐷
#pragma mark >_<! 👉🏻 🐷Event  Response🐷

#pragma mark >_<! 👉🏻 🐷Private Methods🐷
-(void)saveFile{
    if (![self.filePath.pathExtension isEqualToString:@"txt"]) {
        self.filePath = [[self.filePath stringByDeletingPathExtension] stringByAppendingPathExtension:@"txt"];
    }
    NSError * error;
    [self.textView.text writeToFile:self.filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if (!error) {
        if (self.item) {
            ODItemContentRequest *contentRequest = [[[[self.client drive] items:self.item.id] contentRequest] ifMatch:self.item.cTag];
            [self uploadContentRequest:contentRequest fromFile:[NSURL fileURLWithPath:self.filePath]];
        }
    }
}
- (void)uploadContentRequest:(ODItemContentRequest*)contentRequest fromFile:(NSURL *)url{
    ODURLSessionUploadTask *task = [contentRequest uploadFromFile:url completion:^(ODItem *item, NSError *error){
        if (!error) {
            NSLog(@"成功");
        }
//        [self showUploadResponse:item contentRequest:contentRequest fromUrl:url error:error];
    }];
    NSLog(@"--->%@",task);
}
#pragma mark >_<! 👉🏻 🐷Lazy loading🐷
-(UITextView *)textView{
    if (!_textView) {
        _textView = [[UITextView alloc]initWithFrame:self.view.bounds];
    }
    return _textView;
}
#pragma mark >_<! 👉🏻 🐷Init SubViews🐷
-(void)loadDefaultsSetting{
    
}
-(void)initSubViews{
    
    UIButton * save = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    [save setTitle:@"save" forState:UIControlStateNormal];
    [save setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [save addTarget:self action:@selector(saveFile) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:save];
    
    [self.view addSubview:self.textView];
}

@end
