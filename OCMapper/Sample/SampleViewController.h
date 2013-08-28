//
//  SampleViewController.h
//  OCMapper
//
//  Created by Aryan Gh on 8/27/13.
//  Copyright (c) 2013 Aryan Ghassemi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GoogleSearchClient.h"
#import "GoogleSearchResult.h"

@interface SampleViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>

@property (nonatomic, strong) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) GoogleSearchClient *googleSearchclient;
@property (nonatomic, strong) GoogleSearchResponse *googleSearchResponse;

@end
