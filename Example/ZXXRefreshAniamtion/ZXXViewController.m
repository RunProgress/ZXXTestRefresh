//
//  ZXXViewController.m
//  ZXXRefreshAniamtion
//
//  Created by RunProgress on 04/25/2018.
//  Copyright (c) 2018 RunProgress. All rights reserved.
//

#import "ZXXViewController.h"
#import "XXFreshAnimationHeader.h"
#import "UIScrollView+ZXXPullRefresh.h"

static int tally = 0;
@interface ZXXViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong)UITableView *tableView;
@end

@implementation ZXXViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 20, self.view.bounds.size.width, self.view.bounds.size.height - 20)];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    [self.view addSubview:self.tableView];
    [self.tableView addRefreshHeaderWithHandler:^{
        NSLog(@"-------- 执行下拉刷新 --------");
    }];
    
}

- ( void) ThreadProc {
    for(int i = 1; i <= 10000; i++){
        tally += 1;
        NSLog(@"1--%d", i);
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.textLabel.text = [NSString stringWithFormat:@"--- %ld", indexPath.row];
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView.header endRefreshing];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
