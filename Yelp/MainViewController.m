//
//  MainViewController.m
//  Yelp
//
//  Created by Timothy Lee on 3/21/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import "MainViewController.h"
#import "YelpBusiness.h"
#import "BusinessCell.h"
#import "UIImageView+AFNetworking.h"
#import "FiltersViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "MBProgressHUD.h"

#define redColor [UIColor colorWithRed:191.0/255 green:0 blue:0 alpha:1.0];

@interface MainViewController () <UITableViewDataSource, UITableViewDelegate, FiltersViewControllerDelegate, UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UITableView *yelpTableView;
@property (strong, nonatomic) NSArray *businesses;
@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) NSMutableDictionary *filters;
@property (strong, nonatomic) NSMutableDictionary *optionsForSection;


-(void)fetchBusinessesWithQuery:(NSString *)query params:(NSDictionary *)params;
@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.yelpTableView.delegate = self;
    self.yelpTableView.dataSource = self;
    
    self.yelpTableView.estimatedRowHeight = 100.0;
    self.yelpTableView.rowHeight = UITableViewAutomaticDimension;
    self.yelpTableView.allowsSelection = NO;
    
    self.searchBar = [[UISearchBar alloc] init];
    self.searchBar.delegate = self;
    self.searchBar.placeholder = @"Restaurants";
    self.navigationItem.titleView = self.searchBar;
    
    UIButton *filtersButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [filtersButton addTarget:self action:@selector(segueToFilters:) forControlEvents:UIControlEventTouchUpInside];
    [filtersButton setFrame:CGRectMake(0, 0, self.navigationController.view.frame.size.width / 6, self.navigationController.navigationBar.frame.size.height - 16)];
    [filtersButton setTitle:@"Filters" forState:UIControlStateNormal];
    [filtersButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    filtersButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:14];
    filtersButton.backgroundColor = redColor;
    filtersButton.layer.borderColor = [[UIColor whiteColor] CGColor];
    filtersButton.layer.borderWidth = 1;
    filtersButton.layer.cornerRadius = 5;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:filtersButton];
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Filter" style:UIBarButtonItemStylePlain target:self action:@selector(segueToFilters:)];
    self.navigationController.navigationBar.barTintColor = redColor;
    
    self.filters = [NSMutableDictionary dictionary];
    
    [self fetchBusinessesWithQuery:@"" params:nil];
    [self.yelpTableView registerNib:[UINib nibWithNibName:@"BusinessCell" bundle:nil]forCellReuseIdentifier:@"businessCell"];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self fetchBusinessesWithQuery:searchText params:self.filters];
}

- (IBAction)segueToFilters:(id)sender {
    FiltersViewController *vc = [[FiltersViewController alloc] init];
    vc.delegate = self;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)filtersViewController:(FiltersViewController *)filtersViewController didChangeFilters:(NSDictionary *)filters {
    self.filters = [filters mutableCopy];
    [self fetchBusinessesWithQuery:self.searchBar.text params:filters];
    NSLog(@"fire new network event: %@", filters);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.businesses.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BusinessCell *cell = [self.yelpTableView dequeueReusableCellWithIdentifier:@"businessCell" forIndexPath:indexPath];
    YelpBusiness *business = self.businesses[indexPath.row];
    cell.businessCellLabel.text = business.name;
    cell.distanceLabel.text = business.distance;
    cell.reviewsLabel.text = [NSString stringWithFormat:@"%@ Reviews", business.reviewCount];
    cell.addressLabel.text = business.address;
    cell.categoriesLabel.text = business.categories;
    [cell.businessImage setImageWithURL:business.imageUrl];
    cell.businessImage.layer.cornerRadius = 5;
    cell.businessImage.clipsToBounds = YES;
    [cell.ratingsImage setImageWithURL:business.ratingImageUrl];
    return cell;
}

-(void)fetchBusinessesWithQuery:(NSString *)query params:(NSDictionary *)params {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSString *categories = @"";
    if (params[@"category_filter"]) {
        categories = params[@"category_filter"];
    }
    YelpSortMode sortMode = YelpSortModeBestMatched;
    if (params[@"Sort By"]) {
        if ([params[@"Sort By"] intValue] == 1) {
            sortMode = YelpSortModeDistance;
        }
        if ([params[@"Sort By"] intValue] == 2) {
            sortMode = YelpSortModeHighestRated;
        }
    }
    [YelpBusiness searchWithTerm:query
                        sortMode:sortMode
                      categories:@[categories]
                           deals:params[@"Offering a Deal"]
                      completion:^(NSArray *businesses, NSError *error) {
                          self.businesses = businesses;
                          for (YelpBusiness *business in businesses) {
                              NSLog(@"%@", business);
                          }
                          [MBProgressHUD hideHUDForView:self.view animated:YES];
                          [self.yelpTableView reloadData];
                      }];
}

- (void)initOptionsForSection {
    self.optionsForSection = [NSMutableDictionary dictionary];
    
    NSArray *offeringADeal = @[@"Offering a Deal"];
    [self.optionsForSection setObject:offeringADeal forKey:@"Offering a Deal"];
    NSArray *distance = @[@"Auto", @"0.3 miles", @"1 mile", @"5 miles", @"20 miles"];
    [self.optionsForSection setObject:distance forKey:@"Distance"];
    NSArray *sortBy = @[@"Best Match", @"Distance", @"Highest Rated"];
    [self.optionsForSection setObject:sortBy forKey:@"Sort By"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
