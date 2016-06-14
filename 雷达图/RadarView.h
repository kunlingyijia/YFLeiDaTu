//
//  RadarView.h
//  雷达图
//
//  Created by 席亚坤 on 15/6/13.
//  Copyright © 2015年 席亚坤. All rights reserved.
//

//

#import <UIKit/UIKit.h>
#define PI 3.14159265358979323846

@interface RadarView : UIView
- (id)initWithFrame:(CGRect)frame valueDictionary:(NSDictionary *)valueDictionary;

@property (nonatomic, assign) CGFloat valueDivider; // default 1
@property (nonatomic, assign) CGFloat maxValue; // default to the highest value in the dictionary
@property (nonatomic, strong) UIColor *drawboardColor; // defualt black
@property (nonatomic, strong) UIColor *plotColor; // defualt dark grey

-(void)animateWithDuration:(NSTimeInterval)duration valueDictionary:(NSDictionary *)valueDictionary;


@end
