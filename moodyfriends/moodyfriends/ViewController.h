//
//  ViewController.h
//  moodyfriends
//
//  Created by Kyle Langille on 2013-02-09.
//  Copyright (c) 2013 Kyle Langille. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate>{
     NSMutableData *responseData;
}

@end
