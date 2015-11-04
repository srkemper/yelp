//
//  FiltersViewController.m
//  Yelp
//
//  Created by Sean Kemper on 10/29/15.
//  Copyright © 2015 codepath. All rights reserved.
//

#import "FiltersViewController.h"
#import "FilterSwitchCell.h"
#import <QuartzCore/QuartzCore.h>

#define redColor [UIColor colorWithRed:191.0/255 green:0 blue:0 alpha:1.0];
#define cgRedColor [[UIColor colorWithRed:191.0/255 green:0 blue:0 alpha:1.0] CGColor];

@interface FiltersViewController () <UITableViewDataSource, UITableViewDelegate, FilterSwitchCellDelegate>

@property (nonatomic, strong) NSMutableDictionary *filters;
@property (weak, nonatomic) IBOutlet UITableView *filtersTable;
@property (strong, nonatomic) NSArray *categories;
@property (strong, nonatomic) NSMutableSet *selectedCategories;
@property (strong, nonatomic) NSArray *sections;
@property (strong, nonatomic) NSMutableDictionary *optionsForSection;


-(void)initCategories;

@end

@implementation FiltersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.sections = @[@"Offering a Deal", @"Distance", @"Sort By", @"Category"];
    [self initOptionsForSection];
    [self.filtersTable reloadData];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(onCancel)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Apply" style:UIBarButtonItemStylePlain target:self action:@selector(onApply)];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
    self.navigationItem.title = @"Filters";
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    self.navigationController.navigationBar.barTintColor = redColor;
    
    self.filtersTable.delegate = self;
    self.filtersTable.dataSource = self;
    self.filtersTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.filtersTable registerNib:[UINib nibWithNibName:@"FilterSwitchCell" bundle:nil] forCellReuseIdentifier:@"FilterSwitchCell"];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        self.selectedCategories = [NSMutableSet set];
        [self initCategories];
    }
    
    return self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *sec = self.sections[section];
    NSMutableDictionary *options = self.optionsForSection[sec];
    return options.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sections.count;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 5)];
        [headerView setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.9]];
        return headerView;
    }
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 50)];
    [headerView setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.9]];
    
    // Add a UILabel for the username here
    UILabel *optionTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 8, self.view.bounds.size.width - 24, 34)];
    optionTitleLabel.text = self.sections[section];
    [optionTitleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:16]];
    
    [headerView addSubview:optionTitleLabel];
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 5;
    }
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FilterSwitchCell *fsc = [self.filtersTable dequeueReusableCellWithIdentifier:@"FilterSwitchCell"];
    fsc.delegate = self;
    fsc.on = [self getValueForIndexPath:indexPath];
    
    NSString *filter = self.sections[indexPath.section];
    NSArray *options = [self.optionsForSection objectForKey:filter];
    NSString *option;
    if ([filter isEqualToString:@"Category"]) {
        option = self.categories[indexPath.row][@"name"];
    }
    else {
        option = options[indexPath.row];
    }
    
    fsc.filterLabel.text = option;
    
    fsc.contentView.layer.borderColor = cgRedColor;
    fsc.contentView.layer.borderWidth = .75;
    fsc.contentView.layer.cornerRadius = 5;
    
    return fsc;
}

- (BOOL)getValueForIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
            return [[self.filters objectForKey:@"Offering a Deal"] boolValue];
        case 1:
            return [[self.filters objectForKey:@"Distance"] isEqualToNumber:@(indexPath.row)];
        case 2:
            return [[self.filters objectForKey:@"Sort By"] isEqualToNumber:@(indexPath.row)];
        default:
            return [self.selectedCategories containsObject:self.categories[indexPath.row]];
    }
}

- (void)filterSwitchCell:(FilterSwitchCell *)cell didUpdateValue:(BOOL)value {
    NSIndexPath *indexPath = [self.filtersTable indexPathForCell:cell];
    switch (indexPath.section) {
        case 0: {
            [self.filters setObject:[NSNumber numberWithBool:value] forKey:self.sections[indexPath.section]];
            break;
        }
        case 1:
        case 2: {
            NSNumber *previous = [self.filters objectForKey:self.sections[indexPath.section]];
            if (previous != NULL) {
                FilterSwitchCell *fsc = [self.filtersTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[previous intValue] inSection:indexPath.section]];
                [fsc setOn:NO animated:YES];
            }
            [self.filters setObject:@(indexPath.row) forKey:self.sections[indexPath.section]];
            if (!value) {
                [self.filters removeObjectForKey:self.sections[indexPath.section]];
            }
            break;
        }
        default:
            if (value) {
                [self.selectedCategories addObject:self.categories[indexPath.row]];
            } else {
                [self.selectedCategories removeObject:self.categories[indexPath.row]];
            }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initOptionsForSection {
    self.optionsForSection = [NSMutableDictionary dictionary];
    self.filters = [NSMutableDictionary dictionary];
    
    NSArray *offeringADeal = @[@"Offering a Deal"];
    [self.optionsForSection setObject:offeringADeal forKey:@"Offering a Deal"];
    NSArray *distance = @[@"Auto", @"0.3 miles", @"1 mile", @"5 miles", @"20 miles"];
    [self.optionsForSection setObject:distance forKey:@"Distance"];
    NSArray *sortBy = @[@"Best Match", @"Distance", @"Highest Rated"];
    [self.optionsForSection setObject:sortBy forKey:@"Sort By"];
    [self.optionsForSection setObject:self.categories forKey:@"Category"];
}

- (void)initCategories {
    self.categories = @[@{@"name": @"Afghan", @"code": @"afghani"},
                            @{@"name": @"African", @"code": @"african"},
                            @{@"name": @"American, New", @"code": @"newamerican"},
                            @{@"name": @"American, Traditional", @"code": @"tradamerican"},
                            @{@"name": @"Arabian", @"code": @"arabian"},
                            @{@"name": @"Argentine", @"code": @"argentine"},
                            @{@"name": @"Armenian", @"code": @"armenian"},
                            @{@"name": @"Asian Fusion", @"code": @"asianfusion"},
                            @{@"name": @"Asturian", @"code": @"asturian"},
                            @{@"name": @"Australian", @"code": @"australian"},
                            @{@"name": @"Austrian", @"code": @"austrian"},
                            @{@"name": @"Baguettes", @"code": @"baguettes"},
                            @{@"name": @"Bangladeshi", @"code": @"bangladeshi"},
                            @{@"name": @"Barbeque", @"code": @"bbq"},
                            @{@"name": @"Basque", @"code": @"basque"},
                            @{@"name": @"Bavarian", @"code": @"bavarian"},
                            @{@"name": @"Beer Garden", @"code": @"beergarden"},
                            @{@"name": @"Beer Hall", @"code": @"beerhall"},
                            @{@"name": @"Beisl", @"code": @"beisl"},
                            @{@"name": @"Belgian", @"code": @"belgian"},
                            @{@"name": @"Bistros", @"code": @"bistros"},
                            @{@"name": @"Black Sea", @"code": @"blacksea"},
                            @{@"name": @"Brasseries", @"code": @"brasseries"},
                            @{@"name": @"Brazilian", @"code": @"brazilian"},
                            @{@"name": @"Breakfast & Brunch", @"code": @"breakfast_brunch"},
                            @{@"name": @"British", @"code": @"british"},
                            @{@"name": @"Buffets", @"code": @"buffets"},
                            @{@"name": @"Bulgarian", @"code": @"bulgarian"},
                            @{@"name": @"Burgers", @"code": @"burgers"},
                            @{@"name": @"Burmese", @"code": @"burmese"},
                            @{@"name": @"Cafes", @"code": @"cafes"},
                            @{@"name": @"Cafeteria", @"code": @"cafeteria"},
                            @{@"name": @"Cajun/Creole", @"code": @"cajun"},
                            @{@"name": @"Cambodian", @"code": @"cambodian"},
                            @{@"name": @"Canadian", @"code": @"New)"},
                            @{@"name": @"Canteen", @"code": @"canteen"},
                            @{@"name": @"Caribbean", @"code": @"caribbean"},
                            @{@"name": @"Catalan", @"code": @"catalan"},
                            @{@"name": @"Chech", @"code": @"chech"},
                            @{@"name": @"Cheesesteaks", @"code": @"cheesesteaks"},
                            @{@"name": @"Chicken Shop", @"code": @"chickenshop"},
                            @{@"name": @"Chicken Wings", @"code": @"chicken_wings"},
                            @{@"name": @"Chilean", @"code": @"chilean"},
                            @{@"name": @"Chinese", @"code": @"chinese"},
                            @{@"name": @"Comfort Food", @"code": @"comfortfood"},
                            @{@"name": @"Corsican", @"code": @"corsican"},
                            @{@"name": @"Creperies", @"code": @"creperies"},
                            @{@"name": @"Cuban", @"code": @"cuban"},
                            @{@"name": @"Curry Sausage", @"code": @"currysausage"},
                            @{@"name": @"Cypriot", @"code": @"cypriot"},
                            @{@"name": @"Czech", @"code": @"czech"},
                            @{@"name": @"Czech/Slovakian", @"code": @"czechslovakian"},
                            @{@"name": @"Danish", @"code": @"danish"},
                            @{@"name": @"Delis", @"code": @"delis"},
                            @{@"name": @"Diners", @"code": @"diners"},
                            @{@"name": @"Dumplings", @"code": @"dumplings"},
                            @{@"name": @"Eastern European", @"code": @"eastern_european"},
                            @{@"name": @"Ethiopian", @"code": @"ethiopian"},
                            @{@"name": @"Fast Food", @"code": @"hotdogs"},
                            @{@"name": @"Filipino", @"code": @"filipino"},
                            @{@"name": @"Fish & Chips", @"code": @"fishnchips"},
                            @{@"name": @"Fondue", @"code": @"fondue"},
                            @{@"name": @"Food Court", @"code": @"food_court"},
                            @{@"name": @"Food Stands", @"code": @"foodstands"},
                            @{@"name": @"French", @"code": @"french"},
                            @{@"name": @"French Southwest", @"code": @"sud_ouest"},
                            @{@"name": @"Galician", @"code": @"galician"},
                            @{@"name": @"Gastropubs", @"code": @"gastropubs"},
                            @{@"name": @"Georgian", @"code": @"georgian"},
                            @{@"name": @"German", @"code": @"german"},
                            @{@"name": @"Giblets", @"code": @"giblets"},
                            @{@"name": @"Gluten-Free", @"code": @"gluten_free"},
                            @{@"name": @"Greek", @"code": @"greek"},
                            @{@"name": @"Halal", @"code": @"halal"},
                            @{@"name": @"Hawaiian", @"code": @"hawaiian"},
                            @{@"name": @"Heuriger", @"code": @"heuriger"},
                            @{@"name": @"Himalayan/Nepalese", @"code": @"himalayan"},
                            @{@"name": @"Hong Kong Style Cafe", @"code": @"hkcafe"},
                            @{@"name": @"Hot Dogs", @"code": @"hotdog"},
                            @{@"name": @"Hot Pot", @"code": @"hotpot"},
                            @{@"name": @"Hungarian", @"code": @"hungarian"},
                            @{@"name": @"Iberian", @"code": @"iberian"},
                            @{@"name": @"Indian", @"code": @"indpak"},
                            @{@"name": @"Indonesian", @"code": @"indonesian"},
                            @{@"name": @"International", @"code": @"international"},
                            @{@"name": @"Irish", @"code": @"irish"},
                            @{@"name": @"Island Pub", @"code": @"island_pub"},
                            @{@"name": @"Israeli", @"code": @"israeli"},
                            @{@"name": @"Italian", @"code": @"italian"},
                            @{@"name": @"Japanese", @"code": @"japanese"},
                            @{@"name": @"Jewish", @"code": @"jewish"},
                            @{@"name": @"Kebab", @"code": @"kebab"},
                            @{@"name": @"Korean", @"code": @"korean"},
                            @{@"name": @"Kosher", @"code": @"kosher"},
                            @{@"name": @"Kurdish", @"code": @"kurdish"},
                            @{@"name": @"Laos", @"code": @"laos"},
                            @{@"name": @"Laotian", @"code": @"laotian"},
                            @{@"name": @"Latin American", @"code": @"latin"},
                            @{@"name": @"Live/Raw Food", @"code": @"raw_food"},
                            @{@"name": @"Lyonnais", @"code": @"lyonnais"},
                            @{@"name": @"Malaysian", @"code": @"malaysian"},
                            @{@"name": @"Meatballs", @"code": @"meatballs"},
                            @{@"name": @"Mediterranean", @"code": @"mediterranean"},
                            @{@"name": @"Mexican", @"code": @"mexican"},
                            @{@"name": @"Middle Eastern", @"code": @"mideastern"},
                            @{@"name": @"Milk Bars", @"code": @"milkbars"},
                            @{@"name": @"Modern Australian", @"code": @"modern_australian"},
                            @{@"name": @"Modern European", @"code": @"modern_european"},
                            @{@"name": @"Mongolian", @"code": @"mongolian"},
                            @{@"name": @"Moroccan", @"code": @"moroccan"},
                            @{@"name": @"New Zealand", @"code": @"newzealand"},
                            @{@"name": @"Night Food", @"code": @"nightfood"},
                            @{@"name": @"Norcinerie", @"code": @"norcinerie"},
                            @{@"name": @"Open Sandwiches", @"code": @"opensandwiches"},
                            @{@"name": @"Oriental", @"code": @"oriental"},
                            @{@"name": @"Pakistani", @"code": @"pakistani"},
                            @{@"name": @"Parent Cafes", @"code": @"eltern_cafes"},
                            @{@"name": @"Parma", @"code": @"parma"},
                            @{@"name": @"Persian/Iranian", @"code": @"persian"},
                            @{@"name": @"Peruvian", @"code": @"peruvian"},
                            @{@"name": @"Pita", @"code": @"pita"},
                            @{@"name": @"Pizza", @"code": @"pizza"},
                            @{@"name": @"Polish", @"code": @"polish"},
                            @{@"name": @"Portuguese", @"code": @"portuguese"},
                            @{@"name": @"Potatoes", @"code": @"potatoes"},
                            @{@"name": @"Poutineries", @"code": @"poutineries"},
                            @{@"name": @"Pub Food", @"code": @"pubfood"},
                            @{@"name": @"Rice", @"code": @"riceshop"},
                            @{@"name": @"Romanian", @"code": @"romanian"},
                            @{@"name": @"Rotisserie Chicken", @"code": @"rotisserie_chicken"},
                            @{@"name": @"Rumanian", @"code": @"rumanian"},
                            @{@"name": @"Russian", @"code": @"russian"},
                            @{@"name": @"Salad", @"code": @"salad"},
                            @{@"name": @"Sandwiches", @"code": @"sandwiches"},
                            @{@"name": @"Scandinavian", @"code": @"scandinavian"},
                            @{@"name": @"Scottish", @"code": @"scottish"},
                            @{@"name": @"Seafood", @"code": @"seafood"},
                            @{@"name": @"Serbo Croatian", @"code": @"serbocroatian"},
                            @{@"name": @"Signature Cuisine", @"code": @"signature_cuisine"},
                            @{@"name": @"Singaporean", @"code": @"singaporean"},
                            @{@"name": @"Slovakian", @"code": @"slovakian"},
                            @{@"name": @"Soul Food", @"code": @"soulfood"},
                            @{@"name": @"Soup", @"code": @"soup"},
                            @{@"name": @"Southern", @"code": @"southern"},
                            @{@"name": @"Spanish", @"code": @"spanish"},
                            @{@"name": @"Steakhouses", @"code": @"steak"},
                            @{@"name": @"Sushi Bars", @"code": @"sushi"},
                            @{@"name": @"Swabian", @"code": @"swabian"},
                            @{@"name": @"Swedish", @"code": @"swedish"},
                            @{@"name": @"Swiss Food", @"code": @"swissfood"},
                            @{@"name": @"Tabernas", @"code": @"tabernas"},
                            @{@"name": @"Taiwanese", @"code": @"taiwanese"},
                            @{@"name": @"Tapas Bars", @"code": @"tapas"},
                            @{@"name": @"Tapas/Small Plates", @"code": @"tapasmallplates"},
                            @{@"name": @"Tex-Mex", @"code": @"tex-mex"},
                            @{@"name": @"Thai", @"code": @"thai"},
                            @{@"name": @"Traditional Norwegian", @"code": @"norwegian"},
                            @{@"name": @"Traditional Swedish", @"code": @"traditional_swedish"},
                            @{@"name": @"Trattorie", @"code": @"trattorie"},
                            @{@"name": @"Turkish", @"code": @"turkish"},
                            @{@"name": @"Ukrainian", @"code": @"ukrainian"},
                            @{@"name": @"Uzbek", @"code": @"uzbek"},
                            @{@"name": @"Vegan", @"code": @"vegan"},
                            @{@"name": @"Vegetarian", @"code": @"vegetarian"},
                            @{@"name": @"Venison", @"code": @"venison"},
                            @{@"name": @"Vietnamese", @"code": @"vietnamese"},
                            @{@"name": @"Wok", @"code": @"wok"},
                            @{@"name": @"Wraps", @"code": @"wraps"},
                            @{@"name": @"Yugoslav", @"code": @"yugoslav"}];
}

- (void)onCancel {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onApply {
    if (self.selectedCategories.count > 0) {
        NSMutableArray *names = [NSMutableArray array];
        for (NSDictionary *category in self.selectedCategories) {
            [names addObject:category[@"code"]];
        }
        NSString *categoryFilter = [names componentsJoinedByString:@","];
        [self.filters setObject:categoryFilter forKey:@"category_filter"];
    }
    [self.delegate filtersViewController:self didChangeFilters:self.filters];
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
