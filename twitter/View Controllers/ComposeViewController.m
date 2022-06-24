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

@interface ComposeViewController () <UITextViewDelegate>;

@property (weak, nonatomic) IBOutlet UITextView *tweetText;
@property (weak, nonatomic) IBOutlet UILabel *characterCount;

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
    self.tweetText.delegate = self;
    self.characterCount.text = 0;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    // Set the max character limit
    int characterLimit = 140;

    // Construct what the new text would be if we allowed the user's latest edit
    NSString *newText = [self.tweetText.text stringByReplacingCharactersInRange:range withString:text];

    self.characterCount.text = [NSString stringWithFormat:@"%lu", newText.length];
    // Should the new text should be allowed? True/False
    return newText.length < characterLimit;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
}

@end
