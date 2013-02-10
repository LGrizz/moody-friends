//
//  OtherUserViewController.h
//  moodyfriends
//
//  Created by Kyle Langille on 2013-02-09.
//  Copyright (c) 2013 Kyle Langille. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OtherUserViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>{
    NSDictionary *user;
}

@property (nonatomic, retain) NSDictionary *user;

@end
