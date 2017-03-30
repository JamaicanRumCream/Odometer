//
//  PAVOdometerView.m
//  Odometer
//
//  Created by Chris Paveglio on 3/19/17.
//  Copyright © 2017 Paveglio.com. All rights reserved.
//

#import "PAVOdometerView.h"
#import "UIImage+Additions.h"
#import "NSString+Additions.h"


#define KDefaultNumberOfDigits 5
#define KDefaultAnimationTime 3.0


@interface PAVOdometerView ()

/** Number of digits/columns to display
 NOTE: This property will scale number columns as needed so the associated image assets
 should be size appropriately to fit in the space allotted
 */
@property (nonatomic, assign) NSUInteger numberOfDigits;

@property (nonatomic, strong) NSArray *dialNumbers;
@property (nonatomic, assign) CGSize numberColumnSize;
@property (nonatomic, strong) UIColor *numberPattern;

@end


@implementation PAVOdometerView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _numberOfDigits = KDefaultNumberOfDigits;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _numberOfDigits = KDefaultNumberOfDigits;
    }
    return self;
}

- (void)setupOdometerWithStartingNumber:(NSUInteger)startingNumber endingNumber:(NSUInteger)endingNumber animationTime:(CGFloat)animationTime numberColumnImage:(UIImage *)numberColumnImage odometerFrameImage:(UIImage *)odometerFrameImage {
    
    _startingNumber = startingNumber;
    _endingNumber = endingNumber;
    _animationTime = animationTime ? : KDefaultAnimationTime;
    _numberColumnImage = numberColumnImage;
    _odometerFrameImage = odometerFrameImage;
    
    // If an image is provided, add the image view into view
    if (odometerFrameImage) {
        UIImageView *bezelImageView = [[UIImageView alloc] initWithImage:self.odometerFrameImage];
        [bezelImageView setContentMode:UIViewContentModeScaleToFill];
        [self addSubview:bezelImageView];
        [self.leftAnchor constraintEqualToAnchor:bezelImageView.leftAnchor].active = YES;
        [self.topAnchor constraintEqualToAnchor:bezelImageView.topAnchor].active = YES;
        [self.rightAnchor constraintEqualToAnchor:bezelImageView.rightAnchor].active = YES;
        [self.bottomAnchor constraintEqualToAnchor:bezelImageView.bottomAnchor].active = YES;
    }
    
    CGFloat columnWidth = self.frame.size.width / (CGFloat)self.numberOfDigits;
    CGFloat columnHeight = columnWidth * 10.0;
    self.numberColumnSize = CGSizeMake(columnWidth, columnHeight);
    
    [self createOdometerColumnsWithStartingNumber];
    [self createColumnPattern];
}

/** Creates the global number column color-pattern */
- (void)createColumnPattern {
    UIImage *resizedImage = [self.numberColumnImage scaleToSize:self.numberColumnSize];
    self.numberPattern = [UIColor colorWithPatternImage:resizedImage];
}

- (void)createOdometerColumnsWithStartingNumber {
    //iterate on # of digits to make number column UIImageViews
    //set the size of the column views to be appropriate for the # of rows for view frame size
    NSMutableArray *setup = [NSMutableArray arrayWithCapacity:self.numberOfDigits];
    
    for (int i = 0; i < self.numberOfDigits; i++) {
        //set up the rows at indexes from 0 to X, with 0 on RIGHT as the 1's column
        CGFloat xOffset = self.frame.size.width - ((i + 1) * self.numberColumnSize.width);
        CGRect columnSize = CGRectMake(xOffset, 0, self.numberColumnSize.width, self.numberColumnSize.height);
        UIImageView *columnView = [[UIImageView alloc] initWithFrame:columnSize];
        [columnView setContentMode:UIViewContentModeScaleToFill];
        [columnView setImage:self.numberColumnImage];
        [setup addObject:columnView];
    }
    
    //get the digit offset for the column
    //adjust the frame position for the # to display in the column
    self.dialNumbers = (NSArray *)setup;
    NSArray *digitsArray = [self digitsForNumber:self.endingNumber reversed:YES];
    for (int i = 0; i < self.dialNumbers.count; i++) {
        UIImageView *aView = self.dialNumbers[i];
        [self addSubview:aView];
        //transform the view, don't change its actual frame origin
        CGAffineTransform move = CGAffineTransformMakeTranslation(0, -0.1 * [(NSNumber *)digitsArray[i] floatValue] * self.numberColumnSize.height);
        [aView setTransform:move];
    }
}

- (void)animateToNewNumber:(NSUInteger)newNumber {
    self.endingNumber = newNumber;
    if (self.startingNumber > self.endingNumber) { return; };
    
    NSUInteger differential = self.endingNumber - self.startingNumber;
    NSString *differentialString = [self paddedNumberString:differential];
    NSArray *startDigits = [self digitsForNumber:self.startingNumber reversed:YES];
    
    
    NSMutableArray *giantColumnArray = [NSMutableArray arrayWithCapacity:self.numberOfDigits];
    NSMutableString *addingDigitsString = @"".mutableCopy;
    
    // Make array of giant columns for every column
    for (int i = 0; i < self.numberOfDigits; i++) {
        
        // don't make any unnecessary columns for digits that don't change
        if (![[differentialString substringWithRange:NSMakeRange(i, 1)] isEqualToString:@"0"]) {
           
            // Each subsequent digit column, from L to R, gets digits appended. Each digit power of 10 gets
            // another number added in turn. So differential of (00123) -> 1, 12, 123.
            // Amount to rotate is the number of revolutions a digit makes. The 1's column moves the entire
            // amount of the differential, ie 123 digit moves for a 123 differential. 10's col moves 12.
            [addingDigitsString appendString:[differentialString substringWithRange:NSMakeRange(i, 1)]];
            NSUInteger amountToRotate = [addingDigitsString integerValue];
            
            // Create a huge strip with a patterned number background. In order to avoid subclassing and using CGContextSetPatternPhase,
            // just transform the initial position of the strip up a bit. This will require adding additional rows to total column height.
            // This column always starts with 0 and ends at the final digit, ie for "2 rotating to 8" -> [0,1,2 ... 8]

            // Add 1 more to include the final digit in the height
            UIImageView *giantColumn = [[UIImageView alloc] initWithFrame:CGRectMake(self.numberColumnSize.width * i, 0, self.numberColumnSize.width, (1 + amountToRotate + [(NSNumber *)startDigits[i] integerValue]) * [self digitHeight])];
            [giantColumn setBackgroundColor:self.numberPattern];
            // keep a ref of the column image views
            [giantColumnArray addObject:giantColumn];
            
            // add to the view, and adjust it's initial position to match the start number
            [self addSubview:giantColumn];
            CGAffineTransform move = CGAffineTransformMakeTranslation(0, -1.0 * [(NSNumber *)startDigits[i] floatValue] * [self digitHeight]);
            [giantColumn setTransform:move];
        }
    }
    
    [UIView animateKeyframesWithDuration:self.animationTime delay:0.0 options:nil /*UIViewKeyframeAnimationOptionCalculationModeLinear*/ animations:^{
        
        for (UIImageView *aView in giantColumnArray) {
            // Create the move so it moves the whole columnn is translated to bottom, minus the last digit height
            CGAffineTransform move = CGAffineTransformMakeTranslation(0, -(aView.frame.size.height - [self digitHeight]));
            [aView setTransform:move];
        }
        

        
    } completion:^(BOOL finished) {
        // Put some small column images back on?
        // Set start number to end number?
        NSLog(@" transform done");
    }];
}

/** Puts leading 0's on a number as a string, with # of chars return to be the # of digits in display */
- (NSString *)paddedNumberString:(NSUInteger)aNumber {
    NSString *paddedNumber = [NSString stringWithFormat:@"%0*lu", KDefaultNumberOfDigits, (unsigned long)aNumber];
    return paddedNumber;
}

/** Returns a float number of 1/10th of the digit column height */
- (CGFloat)digitHeight {
    return self.numberColumnSize.height * 0.1;
}

/** Return a single digit for the given number */
- (NSUInteger)digitAtIndex:(int)index forNumber:(NSUInteger)aNumber {
    NSString *numberString = [NSString stringWithFormat:@"%ld", aNumber];
    NSString *digitString = [numberString substringWithRange:NSMakeRange(index, 1)];
    return [digitString integerValue];
}

/** Returns the number as an array of strings */
- (NSArray *)digitsForNumber:(NSUInteger)aNumber reversed:(BOOL)reversed {
    NSString *numberString = [NSString stringWithFormat:@"%ld", aNumber];
    if (reversed) {
        numberString = [numberString reversed];
    }
    NSMutableArray *digitArray = [NSMutableArray array];
    for (int i = 0; i < numberString.length; i++) {
        NSString *digitString = [numberString substringWithRange:NSMakeRange(i, 1)];
        [digitArray addObject:@([digitString integerValue])];
    }
    return digitArray;
}

@end





