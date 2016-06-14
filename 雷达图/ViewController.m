//
//  ViewController.m
//  雷达图
//
//  Created by 席亚坤 on 15/6/13.
//  Copyright © 2015年 席亚坤. All rights reserved.
//

//

#import "ViewController.h"
#import "RadarView.h"
#import "CircleView.h"
@interface ViewController ()
///雷达图
@property(nonatomic,strong) RadarView *radarView;
///圆圈
@property(nonatomic,strong)CircleView *circleView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    NSDictionary *valueDictionary = @{@"基本款": @"7",
                                      @"挨揍指数": @"10",
                                      @"骗姑娘" : @"6",
                                      @"不差钱": @"9",
                                      @"爆炸指数" : @"8"
                                      };

    //创建雷达图
    self.radarView = [[RadarView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width) valueDictionary:valueDictionary];
    [_radarView setMaxValue:10];
    _radarView.plotColor = [UIColor colorWithRed:.8 green:.4 blue:.3 alpha:.7];
       _radarView.transform=CGAffineTransformMakeRotation(M_PI/2*3);
    [self.view addSubview:_radarView];
    
   //创建圆圈
    self.circleView = [[CircleView alloc]initWithFrame:CGRectMake(30, CGRectGetMaxY(_radarView.frame)+50, 100, 100)];
    
    [self.view addSubview:_circleView];
    
    
    
    
    
    
    }


- (IBAction)DianJiAction:(UIButton *)sender {
    NSDictionary *valueDictionary = @{@"基本款": @(arc4random_uniform(9)+1).stringValue,
                                      @"挨揍指数": @(arc4random_uniform(9)+1).stringValue,
                                      @"骗姑娘" : @(arc4random_uniform(9)+1).stringValue,
                                      @"不差钱": @(arc4random_uniform(9)+1).stringValue,
                                      @"爆炸指数" : @(arc4random_uniform(9)+1).stringValue
                                      };
    // NSLog(@"%@",valueDictionary);
    
    [_radarView animateWithDuration:.3 valueDictionary:valueDictionary];
    NSString*  integer = valueDictionary[@"基本款"];
    _circleView.rate =  [integer integerValue]*10;
    [_circleView startAnimation];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
