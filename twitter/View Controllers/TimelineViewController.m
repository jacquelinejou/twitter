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

@interface TimelineViewController ()<UITableViewDataSource,UITableViewDelegate>

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
    // Get timeline
    [[APIManager shared] getHomeTimelineWithCompletion:^(NSArray *tweets, NSError *error) {
        if (tweets) {
            NSLog(@"😎😎😎 Successfully loaded home timeline");
            self.arrayOfTweets = [[NSMutableArray alloc] init];;
            for (Tweet *tweet in tweets) {
                [self.arrayOfTweets addObject:tweet];
            }
            NSLog(@"%@", tweets);
            [self.tableView reloadData];
        } else {
            NSLog(@"😫😫😫 Error getting home timeline: %@", error.localizedDescription);
        }
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrayOfTweets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TweetCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TweetCell" forIndexPath:indexPath];
    Tweet *tweet = self.arrayOfTweets[indexPath.row];
    cell.authorLabel.text = tweet.user.name;
    cell.tweetLabel.text = tweet.text;
    cell.numReplies.text = [NSString stringWithFormat:@"%i", tweet.replyCount];
    cell.numRetweets.text = [NSString stringWithFormat:@"%i", tweet.retweetCount];
    cell.numLikes.text = [NSString stringWithFormat:@"%i", tweet.favoriteCount];
    cell.username.text = tweet.user.screenName;
    cell.date.text = tweet.createdAtString;
    UIImage *image=[[UIImage alloc]init];
    // retweet icon setup
    if (tweet.retweeted) {
        image = [UIImage imageNamed:@"retweet-icon-green.png"];
    } else {
        image = [UIImage imageNamed:@"retweet-icon.png"];
    }
    cell.retweetImage.image = image;
    // like icon setup
    if (tweet.favorited) {
        image = [UIImage imageNamed:@"favor-icon-red.png"];
    } else {
        image = [UIImage imageNamed:@"favor-icon.png"];
    }
    cell.likeImage.image = image;
    // message icon setup
    image = [UIImage imageNamed:@"reply-icon.png"];
    cell.replyImage.image = image;
    image = [UIImage imageNamed:@"message-icon.png"];
    cell.messageImage.image = image;
    // verified icon setup
    if (tweet.verified) {
        image = [UIImage imageNamed:@"selected-icon.png"];
        cell.verifiedImage.image = image;
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


@end
