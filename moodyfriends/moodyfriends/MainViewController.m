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
    NSDictionary *json;
    NSMutableArray *jsonFiltered;
    IBOutlet UITextField *searchText;
    IBOutlet UIImageView *searchBg;
    BOOL searching;
    BOOL keyShown;
    int tableHeight;
}

-(void)textFieldDidChange{
    if(![searchText.text isEqualToString:@""]){
        jsonFiltered = [[NSMutableArray alloc] init];
    
        for (NSDictionary* user in json)
        {
            NSRange nameRange = [[user objectForKey:@"screen_name"] rangeOfString:searchText.text options:NSCaseInsensitiveSearch];
            if(nameRange.location != NSNotFound)
            {
                [jsonFiltered addObject:user];
            }
        }
        searching = YES;
        [table reloadData];
    }else{
        jsonFiltered = json;
        [table reloadData];
    }
    
    NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:0];
    UITableViewCell *cell = [table cellForRowAtIndexPath:path];
    //[self.view setBackgroundColor:cell.contentView.backgroundColor];
    //name.text = ((ColorCell *)cell).name.text;
    //[profPic setImageWithURL:[NSURL URLWithString:[[((NSArray *)json) objectAtIndex:path] objectForKey:@"profile_url"]] placeholderImage:[UIImage imageNamed:@"twit.png"]];
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
        if([json count] > 0){
            return [json count];
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
    
    if(keyShown){
        searchText.frame = CGRectMake(20, [[UIScreen mainScreen] bounds].size.height-271, searchText.frame.size.width, searchText.frame.size.height);
        searchBg.frame = CGRectMake(0, [[UIScreen mainScreen] bounds].size.height-280, searchBg.frame.size.width, searchBg.frame.size.height);
        table.frame = CGRectMake(0, 0, table.frame.size.width, 290);
    }else{
        
        searchText.frame = CGRectMake(20, 511, searchText.frame.size.width, searchText.frame.size.height);
        searchBg.frame = CGRectMake(0, 503, searchBg.frame.size.width, searchBg.frame.size.height);
        table.frame = CGRectMake(0, 158, table.frame.size.width, 347);
    }
    
    if(searching){
        items = jsonFiltered;
    }else{
       items = (NSArray *)json; 
    }
    
    if([items count] != 0){
    float blueRatio = 255.0f/((float)[items count]/2) * indexPath.row;
    float redRatio = 255.0f/((float)[items count]/2) * (indexPath.row - ([items count]/2));
    float greenRatio1 = 255.0f/((float)[items count]/2) * (indexPath.row - ((float)[items count]/3));
    float greenRatio2 = 255.0f/((float)[items count]/2) * (indexPath.row - (((float)[items count]/3) * 2));
    float blueVal = (0.0f+blueRatio)/255.0f;
    float redVal = (255.0f-redRatio)/255.0f;
    float greenVal = (255.0f-greenRatio1)/255.0f;
    float greenVal2 = (255.0f-greenRatio2)/255.0f;
    if(indexPath.row < ((float)[json count]/2)){
        cell.contentView.backgroundColor = [UIColor colorWithRed:255.0f/255.0f green:greenVal2 blue:blueVal alpha:1.0f];
    }else{
        cell.contentView.backgroundColor = [UIColor colorWithRed:redVal green:greenVal2 blue:255.0f/255.0f alpha:1.0f];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.name.text = [NSString stringWithFormat:@"@%@",[[((NSArray *)items) objectAtIndex:indexPath.row] objectForKey:@"screen_name"] ];
    }else{
        cell.name.text = [NSString stringWithFormat:@"No items found"];
    }
    
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
    CGPoint offset = aScrollView.contentOffset;
    if(offset.y > 0 && offset.y < table.contentSize.height){
        NSIndexPath *path = [table indexPathForRowAtPoint:offset];
        UITableViewCell *cell = [table cellForRowAtIndexPath:path];
        [self.view setBackgroundColor:cell.contentView.backgroundColor];
        name.text = ((ColorCell *)cell).name.text;
        [profPic setImageWithURL:[NSURL URLWithString:[[((NSArray *)json) objectAtIndex:path.row] objectForKey:@"profile_url"]]
                       placeholderImage:[UIImage imageNamed:@"twit.png"]];
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
    
    vc.user = [((NSArray *)json) objectAtIndex:0];
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    [searchText resignFirstResponder];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    
    searchText.frame = CGRectMake(20, 511, searchText.frame.size.width, searchText.frame.size.height);
    searchBg.frame = CGRectMake(0, 503, searchBg.frame.size.width, searchBg.frame.size.height);
    table.frame = CGRectMake(0, 158, table.frame.size.width, table.frame.size.height);
    
    [UIView commitAnimations];
    if([segue.identifier isEqualToString:@"otherUser"]){
        ((OtherUserViewController *)segue.destinationViewController).user = [((NSArray *)json) objectAtIndex:[table indexPathForCell:((UITableViewCell *)sender)].row];
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
    
    
    UISwipeGestureRecognizer *recognizer;
    
    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [[self view] addGestureRecognizer:recognizer];
    
    float blueRatio = 255.0f/15.0f * 0;
    float greenRatio2 = 255.0f/15.f * (0 - 20);
    float blueVal = (0.0f+blueRatio)/255.0f;
    float greenVal2 = (255.0f-greenRatio2)/255.0f;
    [self.view setBackgroundColor:[UIColor colorWithRed:255.0f/255.0f green:greenVal2 blue:blueVal alpha:1.0f]];
    
    NSError* error;
    NSData *myData = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://moodyfriends.herokuapp.com/examples/v1.json"]];
    json = [NSJSONSerialization JSONObjectWithData:myData options:kNilOptions error:&error];
    json = [json objectForKey:@"following"];
    
    [searchText addTarget:self action:@selector(textFieldDidChange) forControlEvents:UIControlEventEditingChanged];
    searching = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide) name:UIKeyboardDidHideNotification object:nil];
    
    keyShown = NO;
    
    tableHeight = 347;

}

-(void)keyboardDidShow{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    
    searchText.frame = CGRectMake(20, [[UIScreen mainScreen] bounds].size.height-271, searchText.frame.size.width, searchText.frame.size.height);
    searchBg.frame = CGRectMake(0, [[UIScreen mainScreen] bounds].size.height-280, searchBg.frame.size.width, searchBg.frame.size.height);
    table.frame = CGRectMake(0, 0, table.frame.size.width, 290);
    
    [UIView commitAnimations];
    
    searchText.text = @"";
    keyShown = YES;
    
    [table reloadData];
}

-(void)keyboardDidHide{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    
    searchText.frame = CGRectMake(20, 511, searchText.frame.size.width, searchText.frame.size.height);
    searchBg.frame = CGRectMake(0, 503, searchBg.frame.size.width, searchBg.frame.size.height);
    table.frame = CGRectMake(0, 158, table.frame.size.width, 347);
    
    [UIView commitAnimations];
    
    
    if([searchText.text isEqualToString:@""]){
        searchText.text = @"Search";
        searching = NO;
        [table reloadData];
    }
    
    keyShown = NO;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
