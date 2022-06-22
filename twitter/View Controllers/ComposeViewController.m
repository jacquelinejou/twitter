//
//  ComposeViewController.m
//  twitter
//
//  Created by jacquelinejou on 6/21/22.
//  Copyright © 2022 Emerson Malca. All rights reserved.
//

#import "ComposeViewController.h"
#import "APIManager.h"
#import "Tweet.h"

@interface ComposeViewController ()

@property (weak, nonatomic) IBOutlet UITextView *tweetText;


@end

@implementation ComposeViewController
- (IBAction)closeText:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

- (IBAction)finishTweet:(id)sender {
    [[APIManager shared] postStatusWithText:self.tweetText.text completion:^(Tweet *tweet, NSError *error) {
        [self dismissViewControllerAnimated:YES completion:nil];
        if(!error){
            [self.delegate didTweet:tweet];
        }
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
}

@end
