//
//  OrdersHistoryViewController.h
//  SmolVoda
//
//  Created by Sergey Kuritsyn on 19.01.14.
//  Copyright (c) 2014 Sergey Kuritsyn. All rights reserved.
//

#import "GeneralViewController.h"

@interface OrdersHistoryViewController : GeneralViewController <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;

- (IBAction)goBack:(id)sender;
@end
