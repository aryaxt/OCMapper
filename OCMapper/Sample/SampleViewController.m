//
//  SampleViewController.m
//  OCMapper
//
//  Created by Aryan Gh on 8/27/13.
//  Copyright (c) 2013 Aryan Ghassemi. All rights reserved.
//

#import "SampleViewController.h"

@implementation SampleViewController

#pragma mark - UIViewController Methods -

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	[self.searchBar becomeFirstResponder];
	self.googleSearchclient = [[GoogleSearchClient alloc] init];
}

#pragma mark - UITableView Methods -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return self.googleSearchResponse.responseData.results.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	GoogleSearchResult *searchResult = [self.googleSearchResponse.responseData.results objectAtIndex:indexPath.row];
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"searchResultCell"];
	cell.textLabel.text = [self stringByStrippingHTML:searchResult.title];
	cell.detailTextLabel.text = [self stringByStrippingHTML:searchResult.content];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	GoogleSearchResult *searchResult = [self.googleSearchResponse.responseData.results objectAtIndex:indexPath.row];
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:searchResult.url]];
}

#pragma mark - UISearchBar MEthods -

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
	[self.googleSearchclient searchWithKeyword:searchBar.text
								 andCompletion:^(GoogleSearchResponse *googleSearchResponse, NSError *error){
		self.googleSearchResponse = googleSearchResponse;
		[self.tableView reloadData];
	}];
	
	[searchBar resignFirstResponder];
}

#pragma mark - Helper MEthods -

- (NSString *)stringByStrippingHTML:(NSString *)htmlString
{
	NSRange r;
	NSString *newString = [htmlString copy];
	
	while ((r = [newString rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound)
		newString = [newString stringByReplacingCharactersInRange:r withString:@""];
	
	return newString;
}

@end
