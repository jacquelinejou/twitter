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

@interface TimelineViewController () <ComposeViewControllerDelegate, UITableViewDataSource, UITableViewDelegate>;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *arrayOfTweets;

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
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrayOfTweets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TweetCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TweetCell" forIndexPath:indexPath];
    Tweet *tweet = self.arrayOfTweets[indexPath.row];
    cell.tweet = tweet;
    cell.authorLabel.text = tweet.user.name;
    cell.tweetLabel.text = tweet.text;
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

@end
