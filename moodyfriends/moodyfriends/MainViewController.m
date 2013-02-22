//
//  MainViewController.m
//  moodyfriends
//
//  Created by Kyle Langille on 2013-02-09.
//  Copyright (c) 2013 Kyle Langille. All rights reserved.
//

#import "MainViewController.h"
#import "MyViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "ColorCell.h"
#import "OtherUserViewController.h"
#import "SDWebImage/UIImageView+WebCache.h"


@interface MainViewController ()

@end

@implementation MainViewController{
    IBOutlet UITableView *table;
    IBOutlet UIImageView *profPic;
    IBOutlet UILabel *name;
    //NSDictionary *json;
    NSMutableArray *jsonFiltered;
    IBOutlet UITextField *searchText;
    IBOutlet UIImageView *searchBg;
    BOOL searching;
    BOOL keyShown;
    int tableHeight;
    UIColor *bottomColor;
    IBOutlet UIImageView *smile;
    UITableViewCell *lastCell;
    UIRefreshControl *refreshCtrl;
    
    NSMutableArray *jsonColored;
    
    IBOutlet UIView *cover;
}

@synthesize json;

-(void)textFieldDidChange{
    if(![searchText.text isEqualToString:@""]){
        jsonFiltered = [[NSMutableArray alloc] init];
    
        for (NSDictionary* user in jsonColored)
        {
            NSRange nameRange = [[user objectForKey:@"name"] rangeOfString:searchText.text options:NSCaseInsensitiveSearch];
            if(nameRange.location != NSNotFound)
            {
                [jsonFiltered addObject:user];
            }
        }
        searching = YES;
        [table reloadData];
    }else{
        jsonFiltered = jsonColored;
        [table reloadData];
    }
    
    //NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:0];
    //UITableViewCell *cell = [table cellForRowAtIndexPath:path];
    //[self.view setBackgroundColor:cell.contentView.backgroundColor];
    //name.text = ((ColorCell *)cell).name.text;
    //[profPic setImageWithURL:[NSURL URLWithString:[[((NSArray *)json) objectAtIndex:path] objectForKey:@"profile_url"]] placeholderImage:[UIImage imageNamed:@"twit.png"]];
    
    table.contentOffset = CGPointMake(0, 0);
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(!searching){
        if([jsonColored count] > 0){
            return [jsonColored count];
        }else{
            return 1;
        }
    }else{
        if([jsonFiltered count] > 0){
            return [jsonFiltered count];
        }else{
            return 1;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"userCell";
    
    ColorCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[ColorCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSArray *items;
    
    /*if(keyShown){
        searchText.frame = CGRectMake(20, [[UIScreen mainScreen] bounds].size.height-271, searchText.frame.size.width, searchText.frame.size.height);
        searchBg.frame = CGRectMake(0, [[UIScreen mainScreen] bounds].size.height-280, searchBg.frame.size.width, searchBg.frame.size.height);
        table.frame = CGRectMake(0, 0, table.frame.size.width, 290);
    }else{
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        searchText.frame = CGRectMake(20, 511, searchText.frame.size.width, searchText.frame.size.height);
        searchBg.frame = CGRectMake(0, screenRect.size.height - searchBg.frame.size.height/2, searchBg.frame.size.width, searchBg.frame.size.height);
        table.frame = CGRectMake(0, 158, table.frame.size.width, 347);
    }*/
    
    if(searching){
       items = jsonFiltered;
    }else{
       items = (NSArray *)jsonColored; 
    }
    
    if([items count] != 0){
        
    cell.contentView.backgroundColor = [[((NSArray *)items) objectAtIndex:indexPath.row] objectForKey:@"color"];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.name.text = [NSString stringWithFormat:@"%@",[[((NSArray *)items) objectAtIndex:indexPath.row] objectForKey:@"name"] ];
    }else{
        cell.name.text = [NSString stringWithFormat:@"No items found"];
    }
    
    CALayer * l = [profPic layer];
    [l setMasksToBounds:YES];
    [l setCornerRadius:5.0];
    
    // You can even add a border
    [l setBorderWidth:0.8];
    [l setBorderColor:[[UIColor whiteColor] CGColor]];
    
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
    CGPoint offset = aScrollView.contentOffset;
    if(offset.y > 0 && offset.y < table.contentSize.height - 290){
        NSIndexPath *path = [table indexPathForRowAtPoint:offset];
        UITableViewCell *cell = [table cellForRowAtIndexPath:path];
        
        int ran = arc4random_uniform(49);
        if(lastCell != cell){
            [smile setImage:[UIImage imageNamed:[NSString stringWithFormat:@"Faces-large-white-%i.png", ran]]];
        }
        lastCell = cell;
        [self.view setBackgroundColor:cell.contentView.backgroundColor];
        cover.backgroundColor = [UIColor whiteColor];
        name.text = ((ColorCell *)cell).name.text;
        if(!searching){
            [profPic setImageWithURL:[NSURL URLWithString:[[((NSArray *)jsonColored) objectAtIndex:path.row] objectForKey:@"profile_url"]]
                       placeholderImage:[UIImage imageNamed:@"UserPlaceHolder.png"]];
        }else{
            [profPic setImageWithURL:[NSURL URLWithString:[[((NSArray *)jsonFiltered) objectAtIndex:path.row] objectForKey:@"profile_url"]]
                    placeholderImage:[UIImage imageNamed:@"UserPlaceHolder.png"]];
        }
    }
    
    if(offset.y < 0){
        NSIndexPath *path = [table indexPathForRowAtPoint:CGPointMake(0, 1)];
        UITableViewCell *cell = [table cellForRowAtIndexPath:path];
        [table setBackgroundColor:cell.contentView.backgroundColor];
    }else if(offset.y > 0){
        [table setBackgroundColor:bottomColor];
    }
    
    if(!searching && !keyShown){
        table.contentSize = CGSizeMake(320, [json count]*60 + 290);
    }else{
        table.contentSize = CGSizeMake(320, [jsonFiltered count]*60 + 100);
    }
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self performSegueWithIdentifier:@"otherUser" sender:[tableView cellForRowAtIndexPath:indexPath]];
}

-(void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer {
    //[self performSegueWithIdentifier:@"personal" sender:self];
    UIStoryboard *storybord = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    MyViewController *vc =[storybord instantiateViewControllerWithIdentifier:@"myView"];
    
    UIViewController *sourceViewController = self;
    UIViewController *destinationController = vc;
    
    CATransition* transition = [CATransition animation];
    transition.duration = .25;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush; //kCATransitionMoveIn; //, kCATransitionPush, kCATransitionReveal, kCATransitionFade
    transition.subtype = kCATransitionFromLeft; //kCATransitionFromLeft, kCATransitionFromRight, kCATransitionFromTop, kCATransitionFromBottom
    
    [sourceViewController.navigationController.view.layer addAnimation:transition forKey:kCATransition];
    [sourceViewController.navigationController pushViewController:destinationController animated:NO];
    
    vc.user = [((NSArray *)jsonColored) objectAtIndex:0];
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    [searchText resignFirstResponder];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    searchText.frame = CGRectMake(20, [UIScreen mainScreen].applicationFrame.size.height - searchText.frame.size.height - 7, searchText.frame.size.width, searchText.frame.size.height);
    searchBg.frame = CGRectMake(0, [UIScreen mainScreen].applicationFrame.size.height - searchBg.frame.size.height, searchBg.frame.size.width, searchBg.frame.size.height);
    table.frame = CGRectMake(0, 158, table.frame.size.width, 347);
    
    [UIView commitAnimations];
    if([segue.identifier isEqualToString:@"otherUser"]){
        if(!searching){
            ((OtherUserViewController *)segue.destinationViewController).user = [((NSArray *)jsonColored) objectAtIndex:[table indexPathForCell:((UITableViewCell *)sender)].row];
        }else{
            ((OtherUserViewController *)segue.destinationViewController).user = [((NSArray *)jsonFiltered) objectAtIndex:[table indexPathForCell:((UITableViewCell *)sender)].row];
        }
        [((UIViewController *)segue.destinationViewController).view setBackgroundColor:((UITableViewCell *)sender).contentView.backgroundColor];
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    jsonColored = [[NSMutableArray alloc] init];
    
    
    UISwipeGestureRecognizer *recognizer;
    
    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    //[[self view] addGestureRecognizer:recognizer];
    
    float blueRatio = 255.0f/15.0f * 0;
    float greenRatio2 = 255.0f/15.f * (0 - 20);
    float blueVal = (0.0f+blueRatio)/255.0f;
    float greenVal2 = (255.0f-greenRatio2)/255.0f;
    [self.view setBackgroundColor:[UIColor colorWithRed:236.0f/255.0f green:0.0f/255.0f blue:136.0f/255.0f alpha:1.0f]];
    
   /* NSError* error;
    NSData *myData = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://moodyfriends.herokuapp.com/examples/v1.json"]];
    json = [NSJSONSerialization JSONObjectWithData:myData options:kNilOptions error:&error];*/
    //json = [json objectForKey:@"following"];
    
    [searchText addTarget:self action:@selector(textFieldDidChange) forControlEvents:UIControlEventEditingChanged];
    searching = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    
    keyShown = NO;
    
    tableHeight = 347;
    
    int counter = 0;
    for (NSDictionary* user in json)
    {
        counter++;
        float redVal = ((252.0f - 236.0f) / ((float)[json count]/2));
        float redVal2 = 236 + (redVal * counter);
        
        float greenVal = (179 / ((float)[json count]/2));
        float greenVal2 = 0 + (greenVal * counter);
        
        float blueVal = ((136.0f - 21.0f) / ((float)[json count]/2));
        float blueVal2 = 136 - (blueVal * counter);
        
        float redVal3 = 252.0f / ((float)[json count]/2);
        float redVal4 = 252.0f - (redVal3 * (counter - ((float)[json count]/2)));
        
        float greenVal3 = ((179 - 174) / ((float)[json count]/2));
        float greenVal4 = 179 - (greenVal3 * (counter - ((float)[json count]/2)));
        
        float blueVal3 = ((239.0f - 21.0f) / ((float)[json count]/2));
        float blueVal4 = 21 + (blueVal3 * (counter - ((float)[json count]/2)));
        
        NSMutableDictionary *userColored;
        userColored = [user mutableCopy];
        
        if(counter < ((float)[json count]/2)){
            [userColored setValue:[UIColor colorWithRed:redVal2/255.0f green:greenVal2/255.0f blue:blueVal2/255.0f alpha:1.0f] forKey:@"color"];
        }else{
            [userColored setValue:[UIColor colorWithRed:redVal4/255.0f green:greenVal4/255.0f blue:blueVal4/255.0f alpha:1.0f] forKey:@"color"];
        }
        
        [jsonColored addObject:userColored];
    }
    
    jsonFiltered = jsonColored;
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh)
             forControlEvents:UIControlEventValueChanged];
    refreshCtrl = refreshControl;
    
    refreshCtrl.tintColor = [UIColor whiteColor];
    [table addSubview:refreshControl];

}

-(void)refresh {
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://moodyfriends.herokuapp.com/api/feed"] cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:60];
    [request setHTTPMethod:@"POST"];
    
    NSString* postDataString = authString;
    //[postDataString appendFormat:@"authString=%@",responseStr];
    
    // etc..
    
    [request setHTTPBody:[postDataString dataUsingEncoding:NSUTF8StringEncoding]];
    
    [NSURLConnection
     sendAsynchronousRequest:request
     queue:[[NSOperationQueue alloc] init]
     completionHandler:^(NSURLResponse *response,
                         NSData *data,
                         NSError *error)
     {
         
         if ([data length] > 0 && error == nil)
         {
             json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
             NSLog(@"%@", json);
             
             [jsonColored removeAllObjects];
             
             int counter = 0;
             for (NSDictionary* user in json)
             {
                 counter++;
                 float redVal = ((252.0f - 236.0f) / ((float)[json count]/2));
                 float redVal2 = 236 + (redVal * counter);
                 
                 float greenVal = (179 / ((float)[json count]/2));
                 float greenVal2 = 0 + (greenVal * counter);
                 
                 float blueVal = ((136.0f - 21.0f) / ((float)[json count]/2));
                 float blueVal2 = 136 - (blueVal * counter);
                 
                 float redVal3 = 252.0f / ((float)[json count]/2);
                 float redVal4 = 252.0f - (redVal3 * (counter - ((float)[json count]/2)));
                 
                 float greenVal3 = ((179 - 174) / ((float)[json count]/2));
                 float greenVal4 = 179 - (greenVal3 * (counter - ((float)[json count]/2)));
                 
                 float blueVal3 = ((239.0f - 21.0f) / ((float)[json count]/2));
                 float blueVal4 = 21 + (blueVal3 * (counter - ((float)[json count]/2)));
                 
                 NSMutableDictionary *userColored;
                 userColored = [user mutableCopy];
                 
                 if(counter < ((float)[json count]/2)){
                     [userColored setValue:[UIColor colorWithRed:redVal2/255.0f green:greenVal2/255.0f blue:blueVal2/255.0f alpha:1.0f] forKey:@"color"];
                 }else{
                     [userColored setValue:[UIColor colorWithRed:redVal4/255.0f green:greenVal4/255.0f blue:blueVal4/255.0f alpha:1.0f] forKey:@"color"];
                 }
                 
                 [jsonColored addObject:userColored];
             }
             
             [table reloadData];
             [refreshCtrl endRefreshing];
         }
         else if ([data length] == 0 && error == nil)
         {
             NSLog(@"Nothing was downloaded.");
         }
         else if (error != nil){
             NSLog(@"Error = %@", error);
         }
         
     }];
    
    /*// do something here to refresh.
    [NSURLConnection
     sendAsynchronousRequest:authString
     queue:[[NSOperationQueue alloc] init]
     completionHandler:^(NSURLResponse *response,
                         NSData *data,
                         NSError *error)
     {
     
         if ([data length] > 0 && error == nil)
         {
             [refreshCtrl endRefreshing];
     
         }
         else if ([data length] == 0 && error == nil)
         {
             NSLog(@"Nothing was downloaded.");
         }
         else if (error != nil){
             NSLog(@"Error = %@", error);
         }
         
     }];*/
}

-(void)keyboardDidShow:(NSNotification *)aNotification{
    NSDictionary *info = [aNotification userInfo];
    NSValue *aValue = [info objectForKey:UIKeyboardBoundsUserInfoKey];
    CGSize keyboardSize = [aValue CGRectValue].size;
    
    [UIView animateWithDuration:0.3f
                          delay:0.0f
                        options:nil
                     animations:^{
                         searchText.frame = CGRectMake(20, [UIScreen mainScreen].applicationFrame.size.height - keyboardSize.height - searchText.frame.size.height - 7, searchText.frame.size.width, searchText.frame.size.height);
                         searchBg.frame = CGRectMake(0, [UIScreen mainScreen].applicationFrame.size.height - keyboardSize.height - searchBg.frame.size.height, searchBg.frame.size.width, searchBg.frame.size.height);
                         table.frame = CGRectMake(0, 0, table.frame.size.width, 290);
                     }
                     completion:^(BOOL finished) {
                         [table reloadData];
                     }];
    
    if(!searching)
        searchText.text = @"";
    keyShown = YES;
    
    cover.alpha = 1;
    
    if([searchText.text isEqualToString:@""]){
        jsonFiltered = jsonColored;
        [table reloadData];
    }
}

-(void)keyboardDidHide:(NSNotification *)aNotification{
    cover.alpha = 0;

    NSDictionary *info = [aNotification userInfo];
    NSValue *aValue = [info objectForKey:UIKeyboardBoundsUserInfoKey];
    CGSize keyboardSize = [aValue CGRectValue].size;
    
    [UIView animateWithDuration:0.1f
                          delay:0.0f
                        options:nil
                     animations:^{
                         
                         searchText.frame = CGRectMake(20, [UIScreen mainScreen].applicationFrame.size.height - searchText.frame.size.height - 7, searchText.frame.size.width, searchText.frame.size.height);
                         searchBg.frame = CGRectMake(0, [UIScreen mainScreen].applicationFrame.size.height - searchBg.frame.size.height, searchBg.frame.size.width, searchBg.frame.size.height);
                         table.frame = CGRectMake(0, 158, table.frame.size.width, 347);
                     }
                     completion:^(BOOL finished) {
                         [table reloadData];
                     }];
    
    if([searchText.text isEqualToString:@""]){
        searchText.text = @"Search";
        searching = NO;
    }
    
    keyShown = NO;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
