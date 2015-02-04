//
//  ViewController.m
//  Sections
//
//  Created by ZhenjunWang on 2/3/15.
//  Copyright (c) 2015 angeldswang. All rights reserved.
//

#import "ViewController.h"

static NSString *SectionsTableIdentifier = @"SectionsTableIdentifier";

@interface ViewController ()

@property (strong, nonatomic) UISearchController *searchController;
@property (strong, nonatomic) UITableViewController *searchResultsTableViewController;

@property (copy, nonatomic) NSDictionary *names;
@property (copy, nonatomic) NSArray *keys;

@end

@implementation ViewController {
    UITableView *nameTableView;
    NSMutableArray *filteredNames;
//    UISearchDisplayController *searchController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    nameTableView = (id)[self.view viewWithTag:1];
    [nameTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:SectionsTableIdentifier];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"sortednames" ofType:@"plist"];
    
    self.names = [NSDictionary dictionaryWithContentsOfFile:path];
    self.keys = [[self.names allKeys] sortedArrayUsingSelector:@selector(compare:)];
    
    if (nameTableView.style == UITableViewStylePlain) {
        UIEdgeInsets contentInset = nameTableView.contentInset;
        contentInset.top = 20;
        [nameTableView setContentInset:contentInset];
        
        UIView *barBackground = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
        barBackground.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
        [self.view addSubview:barBackground];
    }
    
    filteredNames = [NSMutableArray array];
//  for ios 7
//    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
//    tableView.tableHeaderView = searchBar;
//    searchController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
//    searchController.delegate = self;
//    searchController.searchResultsDataSource = self;

// for ios 8
    // A table view for results.
    UITableView *searchResultsTableView = [[UITableView alloc] initWithFrame:nameTableView.frame];
    searchResultsTableView.dataSource = self;
    searchResultsTableView.delegate = self;
    
    // Registration of reuse identifiers.
    [searchResultsTableView registerClass:UITableViewCell.class forCellReuseIdentifier:SectionsTableIdentifier];
    
    // Init a search results table view controller and setting its table view.
    self.searchResultsTableViewController = [[UITableViewController alloc] init];
    self.searchResultsTableViewController.tableView = searchResultsTableView;
    
    // Init a search controller with its table view controller for results.
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:self.searchResultsTableViewController];
    self.searchController.searchResultsUpdater = self;
    self.searchController.delegate = self;
    
    // Make an appropriate size for search bar and add it as a header view for initial table view.
    [self.searchController.searchBar sizeToFit];
    nameTableView.tableHeaderView = self.searchController.searchBar;
    
    // Enable presentation context.
    self.definesPresentationContext = YES;
    
    
    nameTableView.sectionIndexBackgroundColor = [UIColor blackColor];
    nameTableView.sectionIndexTrackingBackgroundColor = [UIColor darkGrayColor];
    nameTableView.sectionIndexColor = [UIColor whiteColor];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Hide search bar.
    [self dismissSearchBarAnimated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Tabel View Data Source Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView.tag == 1) {
        return [self.keys count];
    } else {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView.tag == 1) {
        NSString *key = self.keys[section];
        NSArray *nameSection = self.names[key];
        return [nameSection count];
    } else {
        return [filteredNames count];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (tableView.tag == 1) {
        return self.keys[section];
    } else {
        return nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SectionsTableIdentifier forIndexPath:indexPath];
    if (tableView.tag == 1) {
        NSString *key = self.keys[indexPath.section];
        NSArray *nameSection = self.names[key];
        cell.textLabel.text = nameSection[indexPath.row];
    } else {
        cell.textLabel.text = filteredNames[indexPath.row];
    }
    
    return cell;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if (tableView.tag == 1) {
        return self.keys;
    } else {
        return nil;
    }
}

#pragma mark - Util methods
- (void)dismissSearchBarAnimated:(BOOL)animated {
    
    CGFloat offset = (self.searchController.searchBar.bounds.size.height) - ([UIApplication sharedApplication].statusBarFrame.size.height);
    
    if (animated) {
        [UIView animateWithDuration:0.5 animations:^{
            nameTableView.contentOffset = CGPointMake(0, offset);
        }];
    } else {
        nameTableView.contentOffset = CGPointMake(0, offset);
    }
}

// for ios 7
//#pragma maker Search Display Delegate Methods
//- (void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView {
//    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:SectionsTableIdentifier];
//}
//
//- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
//    [filteredNames removeAllObjects];
//    if (searchString.length > 0) {
//        NSPredicate *predicte = [NSPredicate predicateWithBlock:^BOOL(NSString *name, NSDictionary *b) {
//            NSRange range = [name rangeOfString:searchString options:NSCaseInsensitiveSearch];
//            return range.location != NSNotFound;
//        }];
//        for (NSString *key in self.keys) {
//            NSArray *matches = [self.names[key] filteredArrayUsingPredicate:predicte];
//            [filteredNames addObjectsFromArray:matches];
//        }
//    }
//    return YES;
//}

#pragma maker Search Results Update Methods
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    UISearchBar *searchBar = searchController.searchBar;
    [filteredNames removeAllObjects];
    if (searchBar.text.length > 0) {
        NSString *text = searchBar.text;
        
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(NSString *name, NSDictionary *bindings) {
            NSRange range = [name rangeOfString:text options:NSCaseInsensitiveSearch];
            
            return range.location != NSNotFound;
        }];
        
        // Set up results.
        for (NSString *key in self.keys) {
            NSArray *matches = [self.names[key] filteredArrayUsingPredicate:predicate];
            [filteredNames addObjectsFromArray:matches];
        }
        
        // Reload search table view.
        [self.searchResultsTableViewController.tableView reloadData];
    }
}

#pragma maker Search Controller Delegate Methods
- (void)didDismissSearchController:(UISearchController *)searchController {
    [self dismissSearchBarAnimated:YES];
}

@end
