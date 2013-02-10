//
//  ViewController.m
//  moodyfriends
//
//  Created by Kyle Langille on 2013-02-09.
//  Copyright (c) 2013 Kyle Langille. All rights reserved.
//

#import "ViewController.h"
#import "TWAPIManager.h"
#import <Twitter/Twitter.h>
#import "TWSignedRequest.h"
#import <Accounts/Accounts.h>
#import "MainViewController.h"

@interface ViewController ()

@property (nonatomic, strong) ACAccountStore *accountStore;
@property (nonatomic, strong) TWAPIManager *apiManager;
@property (nonatomic, strong) NSArray *accounts;
@property (nonatomic, strong) UIButton *reverseAuthBtn;

@end

@implementation ViewController{
    
    IBOutlet UIImageView *face;
    NSData *datar;
}


- (void)actionSheet:(UIActionSheet *)actionSheet
clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSMutableArray *aniImages = [[NSMutableArray alloc] init];
    
    for(int i = 1; i < 50; i++){
        [aniImages addObject:[UIImage imageNamed:[NSString stringWithFormat:@"Faces-large-white-%i.png", i]]];
    }
    
    face.animationImages = aniImages;
    
    face.animationDuration = 8.0;
    face.animationRepeatCount = 0;   // loop forever
    [face startAnimating];
    
    if (buttonIndex != (actionSheet.numberOfButtons - 1)) {
        [_apiManager
         performReverseAuthForAccount:_accounts[buttonIndex]
         withHandler:^(NSData *responseData, NSError *error) {
             if (responseData) {
                 NSString *responseStr = [[NSString alloc]
                                          initWithData:responseData
                                          encoding:NSUTF8StringEncoding];
                 
                 NSArray *parts = [responseStr
                                   componentsSeparatedByString:@"&"];
                 
                 NSString *lined = [parts componentsJoinedByString:@"\n"];
                 
                 dispatch_async(dispatch_get_main_queue(), ^{
                     UIAlertView *alert = [[UIAlertView alloc]
                                           initWithTitle:@"Success!"
                                           message:lined
                                           delegate:nil
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil];
                     //[alert show];
                     NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://moodyfriends.herokuapp.com/api/feed"] cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:60];
                     [request setHTTPMethod:@"POST"];
                     
                     NSMutableString* postDataString = [[NSMutableString alloc] init];
                     //[postDataString appendFormat:@"authString=%@",responseStr];

                     // etc...
                     
                     NSLog(@"%@", responseStr);
                     
                     [request setHTTPBody:[responseStr dataUsingEncoding:NSUTF8StringEncoding]];
                     
                     [NSURLConnection
                      sendAsynchronousRequest:request
                      queue:[[NSOperationQueue alloc] init]
                      completionHandler:^(NSURLResponse *response,
                                          NSData *data,
                                          NSError *error)
                      {
                          
                          if ([data length] > 0 && error == nil)
                          {
                              datar = data;
                              [self performSegueWithIdentifier:@"homeSegue" sender:self];
                          }
                          else if ([data length] == 0 && error == nil)
                          {
                              NSLog(@"Nothing was downloaded.");
                          }
                          else if (error != nil){
                              NSLog(@"Error = %@", error);
                          }
                          
                      }];
                     
                     
                 });
             }
             else {
                 NSLog(@"Error!\n%@", [error localizedDescription]);
             }
         }];
    }
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"homeSegue"]){
        NSError* error;
        ((MainViewController *)segue.destinationViewController).json = [NSJSONSerialization JSONObjectWithData:datar options:kNilOptions error:&error];
    }
}

#pragma mark - Private

- (void)refreshTwitterAccounts
{
    //  Get access to the user's Twitter account(s)
    [self obtainAccessToAccountsWithBlock:^(BOOL granted) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (granted) {
                [self performSelector:@selector(performAuth)];
            }
            else {
                NSLog(@"You were not granted access to the Twitter accounts.");
            }
        });
    }];
}

- (void)obtainAccessToAccountsWithBlock:(void (^)(BOOL))block
{
    ACAccountType *twitterType = [_accountStore
                                  accountTypeWithAccountTypeIdentifier:
                                  ACAccountTypeIdentifierTwitter];
    
    ACAccountStoreRequestAccessCompletionHandler handler =
    ^(BOOL granted, NSError *error) {
        if (granted) {
            self.accounts = [_accountStore accountsWithAccountType:twitterType];
        }
        
        block(granted);
    };
    
    //  This method changed in iOS6.  If the new version isn't available, fall
    //  back to the original (which means that we're running on iOS5+).
    if ([_accountStore
         respondsToSelector:@selector(requestAccessToAccountsWithType:
                                      options:
                                      completion:)]) {
             [_accountStore requestAccessToAccountsWithType:twitterType
                                                    options:nil
                                                 completion:handler];
         }
    else {
        [_accountStore requestAccessToAccountsWithType:twitterType
                                 withCompletionHandler:handler];
    }
}

- (IBAction)performReverseAuth:(id)sender
{
    if ([TWAPIManager isLocalTwitterAccountAvailable]) {
        UIActionSheet *sheet = [[UIActionSheet alloc]
                                initWithTitle:@"Choose an Account"
                                delegate:self
                                cancelButtonTitle:nil
                                destructiveButtonTitle:nil
                                otherButtonTitles:nil];
        
        for (ACAccount *acct in _accounts) {
            [sheet addButtonWithTitle:acct.username];
        }
        
        [sheet addButtonWithTitle:@"Cancel"];
        [sheet setDestructiveButtonIndex:[_accounts count]];
        [sheet showInView:self.view];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"No Accounts"
                              message:@"Please configure a Twitter "
                              "account in the device settings."
                              delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
    }
}

-(void)performAuth{
    if ([TWAPIManager isLocalTwitterAccountAvailable]) {
        UIActionSheet *sheet = [[UIActionSheet alloc]
                                initWithTitle:@"Choose a Twitter account"
                                delegate:self
                                cancelButtonTitle:nil
                                destructiveButtonTitle:nil
                                otherButtonTitles:nil];
        
        for (ACAccount *acct in _accounts) {
            [sheet addButtonWithTitle:acct.username];
        }
        
        [sheet addButtonWithTitle:@"Cancel"];
        [sheet setDestructiveButtonIndex:[_accounts count]];
        [sheet showInView:self.view];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"No Accounts"
                              message:@"Please configure a Twitter "
                              "account in the device settings."
                              delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
    }
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(refreshTwitterAccounts)
     name:ACAccountStoreDidChangeNotification
     object:nil];
    
    _accountStore = [[ACAccountStore alloc] init];
    _apiManager = [[TWAPIManager alloc] init];
	// Do any additional setup after loading the view, typically from a nib.
    
    CGRect appFrame = [UIScreen mainScreen].applicationFrame;
    
    CGRect buttonFrame = appFrame;
    buttonFrame.origin.y = floorf(0.75f * appFrame.size.height);
    buttonFrame.size.height = 44.0f;
    buttonFrame = CGRectInset(buttonFrame, 20, 0);
    
    _reverseAuthBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_reverseAuthBtn setTitle:@"Perform Token Exchange"
                     forState:UIControlStateNormal];
    [_reverseAuthBtn addTarget:self
                        action:@selector(performReverseAuth:)
              forControlEvents:UIControlEventTouchUpInside];
    _reverseAuthBtn.frame = buttonFrame;
    _reverseAuthBtn.enabled = NO;
    [_reverseAuthBtn setTitleColor:[UIColor blackColor]
                          forState:UIControlStateNormal];
    //[self.view addSubview:_reverseAuthBtn];
    
    [self refreshTwitterAccounts];
}

-(void)viewDidAppear:(BOOL)animated{
    //[self performSelector:@selector(performAuth)];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end