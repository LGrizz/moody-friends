//
//  MainViewController.h
//  moodyfriends
//
//  Created by Kyle Langille on 2013-02-09.
//  Copyright (c) 2013 Kyle Langille. All rights reserved.
//

#import "ViewController.h"

@interface MainViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>{
    
    NSDictionary *json;
    NSString *authString;

}

@property (nonatomic, strong) NSDictionary *json;
@property (nonatomic, strong) NSString *authString;

@end
