//
//  ViewController.m
//  Odometer
//
//  Created by Chris Paveglio on 3/19/17.
//  Copyright © 2017 Paveglio.com. All rights reserved.
//

#import "ViewController.h"
#import "PAVOdometerView.h"

@interface ViewController ()

@property (strong, nonatomic) IBOutlet PAVOdometerView *odometerView;
@property (strong, nonatomic) IBOutlet UITextField *animateToThisNumberTF;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)setup:(id)sender {
    [self.odometerView setupOdometerWithStartingNumber:11111 numberColumnImage:[UIImage imageNamed:@"NumberColumn.png"] odometerFrameImage:nil];
}

- (IBAction)animate:(id)sender {
    [self.odometerView animateToNumber:[[self.animateToThisNumberTF text] integerValue] animationTime:4.0];
}


@end
