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
    [self.odometerView setupOdometerWithStartingNumber:11111 endingNumber:11111 numberOfDigits:5 animationTime:10.0 numberColumnImage:[UIImage imageNamed:@"NumberColumn.png"] odometerFrameImage:nil];
}

- (IBAction)animate:(id)sender {
    [self.odometerView animateToNewNumber:[[self.animateToThisNumberTF text] integerValue]];
}


@end