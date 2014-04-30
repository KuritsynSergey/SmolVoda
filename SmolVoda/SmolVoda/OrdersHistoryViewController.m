//
//  OrdersHistoryViewController.m
//  SmolVoda
//
//  Created by Sergey Kuritsyn on 19.01.14.
//  Copyright (c) 2014 Sergey Kuritsyn. All rights reserved.
//

#import "OrdersHistoryViewController.h"
#import "Keys.h"
#import "MainLogic.h"

@interface OrdersHistoryViewController ()

@end

@implementation OrdersHistoryViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    _backgroundImageView.image = [UIImage imageNamed:@"LoginBackground.png"];
}

- (void)viewWillAppear:(BOOL)animated {
    [_tableView deselectRowAtIndexPath:[_tableView indexPathForSelectedRow] animated:animated];
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender { //Подготовка к переходу на следующий экран, передаем далее индекс выбанного заказа
    if ([segue.identifier isEqualToString:@"FromHistory"]) {
        UIViewController *destination = segue.destinationViewController;
        NSIndexPath *indexPath = [_tableView indexPathForCell:sender];
        [destination setValue:[NSNumber numberWithInt:indexPath.row] forKey:@"selectedOrder"];
    }
}

#pragma mark - TableView Delegate

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[MainLogic shared] orders] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40.0;
}

#pragma mark - TableView Data Source

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"item";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = [UIColor colorWithRed:99.0/255.0 green:183.0/255.0 blue:224.0/255.0 alpha:0.5];
//    bgColorView.layer.cornerRadius = 7;
//    bgColorView.layer.masksToBounds = YES;
    [cell setSelectedBackgroundView:bgColorView];
    bgColorView = nil;
    if ([cell viewWithTag:1] == nil) {
        CustomLabel *label = [[CustomLabel alloc] initWithFrame:cell.bounds];
        label.text = [[[MainLogic shared] orders][indexPath.row] objectForKey:kOrderDateKey];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont fontWithName:label.font.fontName size:22];
        label.backgroundColor = [UIColor clearColor];
        label.tag = 1;
        label.textColor = [UIColor colorWithRed:11.0/255.0 green:68.0/255.0 blue:141.0/255.0 alpha:1.0];
        
        [cell addSubview:label];
        label = nil;
    }
    
    return cell;
}

#pragma mark - IBActions

- (IBAction)goBack:(id)sender { //Кнопка "Назад" -- анимация
    CATransition *transition = [CATransition animation];
    transition.duration = 0.3;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromLeft;
    [self.view.window.layer addAnimation:transition forKey:nil];
    
    [self dismissViewControllerAnimated:NO completion:nil];
}

@end
