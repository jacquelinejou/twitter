//
//  TweetDetailsViewController.m
//  twitter
//
//  Created by jacquelinejou on 6/22/22.
//  Copyright © 2022 Emerson Malca. All rights reserved.
//

#import "TweetDetailsViewController.h"
#import "DateTools.h"
#import "APIManager.h"

@interface TweetDetailsViewController ()
@property (strong, nonatomic) IBOutlet UIView *tweetDetailsView;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *userLabel;
@property (weak, nonatomic) IBOutlet UILabel *username;
@property (weak, nonatomic) IBOutlet UIImageView *verifiedImage;
@property (weak, nonatomic) IBOutlet UILabel *tweetText;
@property (weak, nonatomic) IBOutlet UILabel *numRetweets;
@property (weak, nonatomic) IBOutlet UILabel *numQuoteTweets;
@property (weak, nonatomic) IBOutlet UILabel *numLikes;
@property (weak, nonatomic) IBOutlet UIButton *didReply;
@property (weak, nonatomic) IBOutlet UIButton *didRetweet;
@property (weak, nonatomic) IBOutlet UIButton *didLike;
@property (weak, nonatomic) IBOutlet UIButton *didShare;
@property (weak, nonatomic) IBOutlet UILabel *date;

@end

@implementation TweetDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"%@", self.detailTweet);
    // profile picture setup
    NSString *URLString = self.detailTweet.user.profilePicture;
    NSURL *url = [NSURL URLWithString:URLString];
    NSData *urlData = [NSData dataWithContentsOfURL:url];
    self.profileImage.image = [UIImage imageWithData:urlData];
    self.userLabel.text = self.detailTweet.user.name;
    self.username.text = self.detailTweet.user.screenName;
    UIImage *image = [[UIImage alloc] init];
    // setup verified icon
    if (self.detailTweet.user.verified) {
        image = [UIImage imageNamed:@"selected-icon.png"];
        self.verifiedImage.image = image;
    }
    self.tweetText.text = self.detailTweet.text;
    self.numRetweets.text = [NSString stringWithFormat:@"%i", self.detailTweet.retweetCount];
    self.numLikes.text = [NSString stringWithFormat:@"%i", self.detailTweet.favoriteCount];
    // setup retweeted icon
    if (self.detailTweet.retweeted) {
        image = [UIImage imageNamed:@"retweet-icon-green.png"];
    } else {
        image = [UIImage imageNamed:@"retweet-icon.png"];
    }
    [self.didRetweet setImage:image forState:UIControlStateNormal];
    // like icon setup
    if (self.detailTweet.favorited) {
        image = [UIImage imageNamed:@"favor-icon-red.png"];
    } else {
        image = [UIImage imageNamed:@"favor-icon.png"];
    }
    [self.didLike setImage:image forState:UIControlStateNormal];
    // message icon setup
    image = [UIImage imageNamed:@"reply-icon.png"];
    [self.didReply setImage:image forState:UIControlStateNormal];
    image = [UIImage imageNamed:@"square.and.arrow.up.png"];
    [self.didShare setImage:image forState:UIControlStateNormal];
    // setup date in time, date format
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    timeFormatter.dateFormat = @"HH:mm:ss E MMM d Z y";
    dateFormatter.dateFormat = @"HH:mm:ss E MMM d Z y";

    // Configure output format
    timeFormatter.dateStyle = NSDateFormatterNoStyle;
    timeFormatter.timeStyle = NSDateFormatterShortStyle;
    dateFormatter.dateStyle = NSDateFormatterShortStyle;
    dateFormatter.timeStyle = NSDateFormatterNoStyle;
    
    NSString *time = [timeFormatter stringFromDate:self.detailTweet.originalDate];
    NSString *day = [dateFormatter stringFromDate:self.detailTweet.originalDate];
    NSString *space = @" • ";
    // Convert Date to String
    NSString *total = [time stringByAppendingString:space];
    self.date.text = [total stringByAppendingString:day];
}

- (IBAction)didTapRetweet:(id)sender {
    if (!self.detailTweet.retweeted) {
        [[APIManager shared] retweet:self.detailTweet completion:^(Tweet *tweet, NSError *error) {
             self.detailTweet.retweeted = YES;
             self.detailTweet.retweetCount += 1;
             // retweet icon setup
             UIImage *image = [[UIImage alloc] init];
             image = [UIImage imageNamed:@"retweet-icon-green.png"];
             [self.didRetweet setImage:image forState:UIControlStateNormal];
             [self refreshData];
         }];
    } else {
        [[APIManager shared] unretweet:self.detailTweet completion:^(Tweet *tweet, NSError *error) {
            self.detailTweet.retweeted = NO;
            self.detailTweet.retweetCount -= 1;
            // retweet icon setup
            UIImage *image = [[UIImage alloc] init];
            image = [UIImage imageNamed:@"retweet-icon.png"];
            [self.didRetweet setImage:image forState:UIControlStateNormal];
            [self refreshData];
        }];
    }
}

- (IBAction)didTapFavorite:(id)sender {
    if (!self.detailTweet.favorited) {
        [[APIManager shared] favorite:self.detailTweet completion:^(Tweet *tweet, NSError *error) {
             self.detailTweet.favorited = YES;
             self.detailTweet.favoriteCount += 1;
             // like icon setup
             UIImage *image = [[UIImage alloc] init];
             image = [UIImage imageNamed:@"favor-icon-red.png"];
             [self.didLike setImage:image forState:UIControlStateNormal];
             [self refreshData];
         }];
    } else {
        [[APIManager shared] unfavorite:self.detailTweet completion:^(Tweet *tweet, NSError *error) {
            self.detailTweet.favorited = NO;
            self.detailTweet.favoriteCount -= 1;
            // like icon setup
            UIImage *image = [[UIImage alloc] init];
            image = [UIImage imageNamed:@"favor-icon.png"];
            [self.didLike setImage:image forState:UIControlStateNormal];
            [self refreshData];
        }];
    }
}

-(void)refreshData {
    NSString *likes = [NSString stringWithFormat:@"%d", self.detailTweet.favoriteCount];
    self.numLikes.text = likes;
    NSString *retweets = [NSString stringWithFormat:@"%d", self.detailTweet.retweetCount];
    self.numRetweets.text = retweets;
}

@end
