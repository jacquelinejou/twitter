//
//  TimelineViewController.m
//  twitter
//
//  Created by emersonmalca on 5/28/18.
//  Copyright © 2018 Emerson Malca. All rights reserved.
//

#import "TimelineViewController.h"
#import "APIManager.h"
#import "AppDelegate.h"
#import "LoginViewController.h"
#import "Tweet.h"
#import "TweetCell.h"
#import "UIImageView+AFNetworking.h"
#import "ComposeViewController.h"
#import "TweetDetailsViewController.h"
#import "InfiniteScrollActivityView.h"

@interface TimelineViewController () <ComposeViewControllerDelegate, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *arrayOfTweets;
@property (assign, nonatomic) BOOL isMoreDataLoading;
@property (nonatomic, strong) InfiniteScrollActivityView* loadingMoreView;

@end

@implementation TimelineViewController
- (IBAction)didTapLogout:(id)sender {
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LoginViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    appDelegate.window.rootViewController = loginViewController;
    [[APIManager shared] logout];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(beginRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:refreshControl atIndex:0];
    // Get timeline
    [[APIManager shared] getHomeTimelineWithCompletion:^(NSArray *tweets, NSError *error) {
        if (tweets) {
            self.arrayOfTweets = [tweets mutableCopy];
            [self.tableView reloadData];
        }
    }];
    self.isMoreDataLoading = false;
    
    // Set up Infinite Scroll loading indicator
    CGRect frame = CGRectMake(0, self.tableView.contentSize.height, self.tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight);
    self.loadingMoreView = [[InfiniteScrollActivityView alloc] initWithFrame:frame];
    self.loadingMoreView.hidden = true;
    [self.tableView addSubview:self.loadingMoreView];
    
    UIEdgeInsets insets = self.tableView.contentInset;
    insets.bottom += InfiniteScrollActivityView.defaultHeight;
    self.tableView.contentInset = insets;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrayOfTweets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TweetCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TweetCell" forIndexPath:indexPath];
    Tweet *tweet = self.arrayOfTweets[indexPath.row];
    cell.tweet = tweet;
    cell.authorLabel.text = tweet.user.name;
    cell.tweetText.text = tweet.text;
    if (cell.tweet.mediaURL) {
        NSData * imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: cell.tweet.mediaURL]];
        cell.tweetImage.image = [UIImage imageWithData: imageData];
    }
    cell.numReplies.text = [NSString stringWithFormat:@"%i", tweet.replyCount];
    cell.numRetweets.text = [NSString stringWithFormat:@"%i", tweet.retweetCount];
    cell.numLikes.text = [NSString stringWithFormat:@"%i", tweet.favoriteCount];
    cell.username.text = tweet.user.screenName;
    cell.date.text = tweet.createdAtString;
    UIImage *image = [[UIImage alloc] init];
    // retweet icon setup
    if (tweet.retweeted) {
        image = [UIImage imageNamed:@"retweet-icon-green.png"];
    } else {
        image = [UIImage imageNamed:@"retweet-icon.png"];
    }
    [cell.retweetImage setImage:image forState:UIControlStateNormal];
    // like icon setup
    if (tweet.favorited) {
        image = [UIImage imageNamed:@"favor-icon-red.png"];
    } else {
        image = [UIImage imageNamed:@"favor-icon.png"];
    }
    [cell.likeImage setImage:image forState:UIControlStateNormal];
    // message icon setup
    image = [UIImage imageNamed:@"reply-icon.png"];
    cell.replyImage.image = image;
    image = [UIImage imageNamed:@"message-icon.png"];
    cell.messageImage.image = image;
    // verified icon setup
    if (tweet.verified) {
        image = [UIImage imageNamed:@"selected-icon.png"];
        cell.verifiedImage.image = image;
        cell.tweet.user.verified = tweet.verified;
    }
    // profile picture setup
    NSString *URLString = tweet.user.profilePicture;
    NSURL *url = [NSURL URLWithString:URLString];
    NSData *urlData = [NSData dataWithContentsOfURL:url];
    cell.profileImage.image = [UIImage imageWithData:urlData];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Makes a network request to get updated data
// Updates the tableView with the new data
// Hides the RefreshControl
- (void)beginRefresh:(UIRefreshControl *)refreshControl {
    [[APIManager shared] getHomeTimelineWithCompletion:^(NSArray *tweets, NSError *error) {
        if (tweets) {
            self.arrayOfTweets = [tweets mutableCopy];
            [self.tableView reloadData];
        }
        // Tell the refreshControl to stop spinning
        [refreshControl endRefreshing];
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ComposeView"]) {
        UINavigationController *navigationController = [segue destinationViewController];
        ComposeViewController *composeController = (ComposeViewController*)navigationController.topViewController;
        composeController.delegate = self;
    } else if ([segue.identifier isEqualToString:@"TweetDetails"]) {
        NSIndexPath *myIndexPath = [self.tableView indexPathForCell:sender];
        Tweet *dataToPass = self.arrayOfTweets[myIndexPath.row];
        TweetDetailsViewController *detailVC = [segue destinationViewController];
        detailVC.detailTweet = dataToPass;
    }
}

- (void)didTweet:(nonnull Tweet *)tweet {
    [self.arrayOfTweets insertObject:tweet atIndex:0];
    [self.tableView reloadData];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if(!self.isMoreDataLoading){
        // Calculate the position of one screen length before the bottom of the results
        int scrollViewContentHeight = self.tableView.contentSize.height;
        int scrollOffsetThreshold = scrollViewContentHeight - self.tableView.bounds.size.height;
        
        // When the user has scrolled past the threshold, start requesting
        if(scrollView.contentOffset.y > scrollOffsetThreshold && self.tableView.isDragging) {
            self.isMoreDataLoading = true;
            // Update position of loadingMoreView, and start loading indicator
            CGRect frame = CGRectMake(0, self.tableView.contentSize.height, self.tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight);
            self.loadingMoreView.frame = frame;
            [self.loadingMoreView startAnimating];
            [self loadMoreData:[self.arrayOfTweets count] + 20];
        }
    }
}

-(void)loadMoreData: (NSInteger)numReloadCells {
    NSNumber *numReload = [NSNumber numberWithInteger:numReloadCells];
    [[APIManager shared] reloadHomeTimeline:numReload completion:^(NSArray *tweets, NSError *error) {
        self.isMoreDataLoading = NO;
        if (tweets) {
            self.arrayOfTweets = [tweets mutableCopy];
            [self.tableView reloadData];
        }
        // Reload the tableView now that there is new data
        [self.tableView reloadData];
    }];
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row + 1 == [self.arrayOfTweets count]){
        [self loadMoreData:[self.arrayOfTweets count] + 20];
    }
}

@end
