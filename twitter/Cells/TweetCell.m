//
//  TweetCell.m
//  twitter
//
//  Created by jacquelinejou on 6/20/22.
//  Copyright © 2022 Emerson Malca. All rights reserved.
//

#import "TweetCell.h"
#import "APIManager.h"

@implementation TweetCell
- (IBAction)didTapFavorite:(UIButton *)sender {
    if (!self.tweet.favorited) {
        [[APIManager shared] favorite:self.tweet completion:^(Tweet *tweet, NSError *error) {
             self.tweet.favorited = YES;
             self.tweet.favoriteCount += 1;
             // like icon setup
             UIImage *image = [[UIImage alloc] init];
             image = [UIImage imageNamed:@"favor-icon-red.png"];
             [self.likeImage setImage:image forState:UIControlStateNormal];
             [self refreshData];
         }];
    } else {
        [[APIManager shared] unfavorite:self.tweet completion:^(Tweet *tweet, NSError *error) {
            self.tweet.favorited = NO;
            self.tweet.favoriteCount -= 1;
            // like icon setup
            UIImage *image = [[UIImage alloc] init];
            image = [UIImage imageNamed:@"favor-icon.png"];
            [self.likeImage setImage:image forState:UIControlStateNormal];
            [self refreshData];
        }];
    }
}

- (IBAction)didTapRetweet:(id)sender {
    if (!self.tweet.retweeted) {
        [[APIManager shared] retweet:self.tweet completion:^(Tweet *tweet, NSError *error) {
             self.tweet.retweeted = YES;
             self.tweet.retweetCount += 1;
             // retweet icon setup
             UIImage *image = [[UIImage alloc] init];
             image = [UIImage imageNamed:@"retweet-icon-green.png"];
             [self.retweetImage setImage:image forState:UIControlStateNormal];
             [self refreshData];
         }];
    } else {
        [[APIManager shared] unretweet:self.tweet completion:^(Tweet *tweet, NSError *error) {
            self.tweet.retweeted = NO;
            self.tweet.retweetCount -= 1;
            // retweet icon setup
            UIImage *image = [[UIImage alloc] init];
            image = [UIImage imageNamed:@"retweet-icon.png"];
            [self.retweetImage setImage:image forState:UIControlStateNormal];
            [self refreshData];
        }];
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

-(void)refreshData {
    NSString *likes = [NSString stringWithFormat:@"%d", self.tweet.favoriteCount];
    self.numLikes.text = likes;
    NSString *retweets = [NSString stringWithFormat:@"%d", self.tweet.retweetCount];
    self.numRetweets.text = retweets;
}

-(void)prepareForReuse{
    [super prepareForReuse];
    self.tweetImage.image = nil;
    // Then Reset here back to default values that you want.
}

@end
