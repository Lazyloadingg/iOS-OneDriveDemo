//
//  ViewController.m
//  OneDriveDemo
//
//  Created by 圣光 on 2018/11/28.
//  Copyright © 2018年 圣光. All rights reserved.
//

#import "ViewController.h"
#import "textViewVC.h"
@interface ViewController ()
<

UITableViewDelegate,
UITableViewDataSource
>

@property(nonatomic,strong)NSMutableArray * dataArr;
@property(nonatomic,strong)UITableView * tableview;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadDefaultsSetting];
    [self initSubViews];
    
    if (self.client) {
        [self getItem];
    }
}
#pragma mark >_<! 👉🏻 🐷Life cycle🐷
#pragma mark >_<! 👉🏻 🐷System Delegate🐷

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArr.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"23333"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"23333"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    ODItem * item = self.dataArr[indexPath.row];
    cell.textLabel.text = item.name;
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    ODItem * item = self.dataArr[indexPath.row];
    if (item.folder) {
        
        ViewController * vc = [[ViewController alloc]init];
        vc.client = self.client;
        vc.currentItem = item;
        [self.navigationController pushViewController:vc animated:YES];
    }else if (item.file){
        NSLog(@"要显示文件了");
        
        ODURLSessionDownloadTask *task = [[[[self.client drive] items:item.id] contentRequest] downloadWithCompletion:^(NSURL *filePath, NSURLResponse *response, NSError *error) {
            if (!error) {
                if ([item.file.mimeType isEqualToString:@"text/plain"]) {
                    NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
                    NSString *newFilePath = [documentPath stringByAppendingPathComponent:item.name];
                    [[NSFileManager defaultManager] moveItemAtURL:filePath toURL:[NSURL fileURLWithPath:newFilePath] error:nil];
                    textViewVC * newController = [[textViewVC alloc]init];
//                    [newController setItemSaveCompletion:^(ODItem *newItem){
//                        if (newItem){
//                            if (![self.itemsLookup containsObject:newItem.id]){
//                                [self.itemsLookup addObject:newItem.id];
//                            }
//                            self.items[newItem.id] = newItem;
//                            dispatch_async(dispatch_get_main_queue(), ^(){
//                                [self.collectionView reloadData];
//                            });
//                        }
//                    }];
                    newController.title = item.name;
                    newController.item = item;
                    newController.client = self.client;
                    newController.filePath = newFilePath;
                    dispatch_async(dispatch_get_main_queue(), ^(){
                        [super.navigationController pushViewController:newController animated:YES];
                    });
                }
            }else{
                NSLog(@"--->%@",error);
            }
        }];
        NSLog(@"----->%@",task);
    }
    NSLog(@"---->%@",item.name);
}
#pragma mark >_<! 👉🏻 🐷Custom Delegate🐷
#pragma mark >_<! 👉🏻 🐷Event  Response🐷
- (IBAction)login:(id)sender {
    [ODClient authenticatedClientWithCompletion:^(ODClient *client, NSError *error) {
        if (!error) {
            self.client = client;
            [self loadChildren];
        }else{
            NSLog(@"认证失败--->%@",error);
        }
    }];
}
- (IBAction)logout:(id)sender {
    if (self.client) {
        [self.client signOutWithCompletion:^(NSError *error) {
            if (!error) {
                NSLog(@"退出成功");
            }else{
                NSLog(@"退出失败--%@",error);
            }
        }];
    }else{
        NSLog(@"尚未登录");
    }
}
- (IBAction)select:(id)sender {
    [self getItem];
}
- (IBAction)upload:(id)sender {
}
-(void)getItem{
    NSString * itemID = (self.currentItem) ? self.currentItem.id : @"root";
    ODChildrenCollectionRequest *childrenRequest = [[[[self.client drive] items:itemID] children] request];
    [childrenRequest getWithCompletion:^(ODCollection *response, ODChildrenCollectionRequest *nextRequest, NSError *error) {
        if (!error) {
            if (response.value) {
                self.dataArr = response.value.mutableCopy;
            }
            for (ODItem * item in response.value) {
                //                NSData * data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
                //                NSString * str = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
                NSLog(@"根目录文件夹---->%@",item.name);
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableview reloadData];
            });
            NSLog(@"获取成功");
        }else{
            NSLog(@"获取失败");
        }
    }];
}
- (void)loadChildren
{
    NSString *itemId = @"root";
    ODChildrenCollectionRequest *childrenRequest = [[[[self.client drive] items:itemId] children] request];
    if (![self.client serviceFlags][@"NoThumbnails"]){
        [childrenRequest expand:@"thumbnails"];
    }
    [self loadChildrenWithRequest:childrenRequest];
}
- (void)loadChildrenWithRequest:(ODChildrenCollectionRequest*)childrenRequests
{
    [childrenRequests getWithCompletion:^(ODCollection *response, ODChildrenCollectionRequest *nextRequest, NSError *error){
        if (!error){
            if (response.value){
                [self onLoadedChildren:response.value];
            }
            if (nextRequest){
                [self loadChildrenWithRequest:nextRequest];
            }
        }
        else if ([error isAuthenticationError]){
//            [self showErrorAlert:error];
            [self onLoadedChildren:@[]];
        }
    }];
}
- (void)onLoadedChildren:(NSArray *)children
{
    NSLog(@"刷新------>%@",children);
//    if (self.refreshControl.isRefreshing){
//        [self.refreshControl endRefreshing];
//    }
//    [children enumerateObjectsUsingBlock:^(ODItem *item, NSUInteger index, BOOL *stop){
//        if (![self.itemsLookup containsObject:item.id]){
//            [self.itemsLookup addObject:item.id];
//        }
//        self.items[item.id] = item;
//    }];
//    [self loadThumbnails:children];
//    dispatch_async(dispatch_get_main_queue(), ^(){
//        [self.collectionView reloadData];
//    });
}
#pragma mark >_<! 👉🏻 🐷Private Methods🐷
#pragma mark >_<! 👉🏻 🐷Lazy loading🐷
-(UITableView *)tableview{
    if (!_tableview) {
        _tableview = [[UITableView alloc]initWithFrame:self.view.bounds];
        _tableview.delegate = self;
        _tableview.dataSource = self;
        _tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
        
    }
    return _tableview;
}
-(NSMutableArray *)dataArr{
    if (!_dataArr) {
        _dataArr =[ NSMutableArray array];
    }
    return _dataArr;
}
#pragma mark >_<! 👉🏻 🐷Init SubViews🐷

-(void)loadDefaultsSetting{
    
}
-(void)initSubViews{
    [self.view addSubview:self.tableview];
}
@end
