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
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [json count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"userCell";
    
    ColorCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[ColorCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    float blueRatio = 255.0f/((float)[json count]/2) * indexPath.row;
    float redRatio = 255.0f/((float)[json count]/2) * (indexPath.row - ([json count]/2));
    float greenRatio1 = 255.0f/((float)[json count]/2) * (indexPath.row - ((float)[json count]/3));
    float greenRatio2 = 255.0f/((float)[json count]/2) * (indexPath.row - (((float)[json count]/3) * 2));
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
    cell.name.text = [ NSString stringWithFormat:@"@%@",[[((NSArray *)json) objectAtIndex:indexPath.row] objectForKey:@"screen_name"] ];
    
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
    NSLog(@"%i", [json count]);

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
