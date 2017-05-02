//
//  PAVOdometerView.m
//  Odometer
//
//  Created by Chris Paveglio on 3/19/17.
//  Copyright © 2017 Paveglio.com. All rights reserved.
//

#import "PAVOdometerView.h"
#import "UIImage+Additions.h"


#define KNumberOfDigits 5


@interface PAVOdometerView ()

/** The initial number to start the odometer at when view is shown */
@property (nonatomic, assign) NSUInteger startingNumber;

/** Number of digits/columns to display
 NOTE: This property will scale number columns as needed so the associated image assets
 should be size appropriately to fit in the space allotted. Highly layout-coupled.
 Use KNumberOfDigits to control.
 */
@property (nonatomic, assign) NSUInteger numberOfDigits;

/** The initial setup creates number columns that do not animate. These static
 numbers are only moved when the animation is complete. They are never removed. */
@property (nonatomic, strong) NSArray *staticDialNumbersArray;

/** The number imageViews that actually animate. This array is populated, animated, and destroyed
 for each animation. */
@property (nonatomic, strong) NSMutableArray *rotatingDialNumberArray;

/** Calculated size of a single number image column view */
@property (nonatomic, assign) CGSize numberColumnSize;

/** UIColor can be an image pattern, how lucky are we?! */
@property (nonatomic, strong) UIColor *numberPattern;

/** Number of seconds to do the animation */
@property (nonatomic, assign) CGFloat animationTime;

@end


@implementation PAVOdometerView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _numberOfDigits = KNumberOfDigits;
        self.rotatingDialNumberArray = [NSMutableArray array];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _numberOfDigits = KNumberOfDigits;
        self.rotatingDialNumberArray = [NSMutableArray array];
    }
    return self;
}

- (void)setupOdometerWithStartingNumber:(NSUInteger)startingNumber numberColumnImage:(UIImage *)numberColumnImage odometerFrameImage:(UIImage *)odometerFrameImage {
    if (!numberColumnImage) {
        NSAssert(false, @"Odometer setup missing the number image");
    }
    _startingNumber = startingNumber ?: 0;
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
    
    // !! IMPORTANT LAYOUT NOTE  - This assumes each digit image is a perfect square
    CGFloat columnWidth = self.frame.size.width / (CGFloat)self.numberOfDigits;
    CGFloat columnHeight = columnWidth * 10.0;
    self.numberColumnSize = CGSizeMake(columnWidth, columnHeight);

    [self createStaticNumberColumns];
    [self moveStaticNumbersToNumber:startingNumber];
    [self createColumnPattern];
}

/** Creates the global number column color-pattern */
- (void)createColumnPattern {
    UIImage *resizedImage = [self.numberColumnImage scaleToSize:self.numberColumnSize];
    self.numberPattern = [UIColor colorWithPatternImage:resizedImage];
}

/** Builds columns of number views in the main view */
- (void)createStaticNumberColumns {
    NSMutableArray *setup = [NSMutableArray arrayWithCapacity:self.numberOfDigits];
    for (int i = 0; i < self.numberOfDigits; i++) {
        //set up the rows at indexes from 0 to X
        CGFloat xOffset = i * self.numberColumnSize.width;
        CGRect columnSize = CGRectMake(xOffset, 0, self.numberColumnSize.width, self.numberColumnSize.height);
        
        UIImageView *columnView = [[UIImageView alloc] initWithFrame:columnSize];
        [columnView setContentMode:UIViewContentModeScaleToFill];
        [columnView setImage:self.numberColumnImage];
        
        [setup addObject:columnView];
        [self addSubview:columnView];
    }
    self.staticDialNumbersArray = (NSArray *)setup;
}

/** Moves the static rows to a number immediately with no animation */
- (void)moveStaticNumbersToNumber:(NSUInteger)aNumber {
    for (int i = 0; i < self.numberOfDigits; i++) {
        UIImageView *aView = self.staticDialNumbersArray[i];
        NSString *numberString = [self paddedNumberString:aNumber];
        
        CGFloat singleDigit = [[numberString substringWithRange:NSMakeRange(i, 1)] floatValue];
        
        //first reset view to "0" offset
        [aView setTransform:CGAffineTransformIdentity];
        //transform the view, don't change its actual frame origin
        CGAffineTransform move = CGAffineTransformMakeTranslation(0, -0.1 * singleDigit * self.numberColumnSize.height);
        [aView setTransform:move];
    }
}

- (void)animateToNumber:(NSUInteger)newNumber animationTime:(CGFloat)animationTime {
    [self animateToNumber:newNumber animationTime:animationTime identifier:nil];
}

- (void)animateToNumber:(NSUInteger)newNumber animationTime:(CGFloat)animationTime identifier:(NSString *)idenfifier {
    self.animationTime = animationTime;
    if (self.startingNumber >= newNumber) { return; };
    // Bail if it's going to go backwards
    
    // The string of the new number with added 00s
    NSString *differentialString = [self paddedNumberString:newNumber - self.startingNumber];
    NSString *startDigitsString = [self paddedNumberString:self.startingNumber];
    NSString *endingDigitsString = [self paddedNumberString:newNumber];
    // An amount that was rolled over from the last time through the loop
    // IE a 10s column that needs to roll over the next higher value column
    NSUInteger rolloverAmount = 0;
    
    // Loop through all columns from the 1s leftward to the 1000s column
    for (int i = (int)self.numberOfDigits - 1; i > -1; i--) {
        
        NSString *thisEndingDigit = [endingDigitsString substringWithRange:NSMakeRange(i, 1)];
        NSString *thisStartDigit = [startDigitsString substringWithRange:NSMakeRange(i, 1)];
        
        // Get number of rotations by chopping off the last digit
        NSString  *diffDigitsUpToHereString = [differentialString substringToIndex:i + 1];
        NSUInteger diffDigitsUpToHere = [diffDigitsUpToHereString integerValue] ;
        
        // The amount to rotate this column, ie the absolute numerical difference
        NSUInteger amountToRotate = diffDigitsUpToHere + rolloverAmount;
        
        // If the end digit is past 0, the end digit is lower than start digit, so we must carry a 1,
        // OR
        // the digits.length is less than the amount to rotate, ie 99 < 100 ie
        // where 1 is carried for 10s or 100s column, so carry a 1 again
        if ([thisEndingDigit integerValue] < [thisStartDigit integerValue] ||
            [[NSString stringWithFormat:@"%ld", diffDigitsUpToHere] length] < [[NSString stringWithFormat:@"%ld", amountToRotate] length]) {
            rolloverAmount = 1;
        } else {
            rolloverAmount = 0;
        }
        
        // Create a huge strip with a patterned number background. In order to avoid subclassing and using CGContextSetPatternPhase,
        // just transform the initial position of the strip up a bit. This will require adding additional rows to total column height.
        // This column always starts with 0 and ends at the final digit, ie for "2 rotating to 8" -> [0,1,2 ... 8]

        // Add 1 more to include the final digit in the height
        UIImageView *giantColumn = [[UIImageView alloc] initWithFrame:CGRectMake(self.numberColumnSize.width * i, 0, self.numberColumnSize.width, (1 + amountToRotate + [thisStartDigit integerValue]) * [self digitHeight])];
        [giantColumn setBackgroundColor:self.numberPattern];
        // keep a ref of the column image views
        [self.rotatingDialNumberArray addObject:giantColumn];
        
        // add to the view, and adjust it's initial position to match the start number
        [self addSubview:giantColumn];
        CGAffineTransform move = CGAffineTransformMakeTranslation(0, -1.0 * [thisStartDigit floatValue] * [self digitHeight]);
        [giantColumn setTransform:move];
        
        // Now there is an animatable column over top of the static number images
    }
    
    [UIView animateKeyframesWithDuration:self.animationTime delay:0.0 options:0 animations:^{
        // default animation options is ease-in-out and looks a bit nicer than hard linear
        // UIViewKeyframeAnimationOptionCalculationModeLinear
        
        for (UIImageView *aView in self.rotatingDialNumberArray) {
            // Create the move so it moves the whole columnn -> translated to bottom, minus the last digit height
            CGAffineTransform move = CGAffineTransformMakeTranslation(0, -(aView.frame.size.height - [self digitHeight]));
            [aView setTransform:move];
        }
        
    } completion:^(BOOL finished) {
        
        // make the start number be the end number, so we can animate again!
        self.startingNumber = newNumber;
        [self moveStaticNumbersToNumber:newNumber];
        
        // Remove all the rotating dials from view and clear the array
        for (UIImageView *aView in self.rotatingDialNumberArray) {
            [aView removeFromSuperview];
        }
        [self.rotatingDialNumberArray removeAllObjects];
        
        if (finished && [self.delegate respondsToSelector:@selector(pavOdometerView:didCompleteWithIdentifier:)]) {
            [self.delegate pavOdometerView:self didCompleteWithIdentifier:idenfifier];
        }
    }];
}

/** Puts leading 0's on a number as a string, with # of chars return to be the # of digits in display */
- (NSString *)paddedNumberString:(NSUInteger)aNumber {
    NSString *paddedNumber = [NSString stringWithFormat:@"%0*lu", KNumberOfDigits, (unsigned long)aNumber];
    return paddedNumber;
}

/** Returns a float number of 1/10th of the digit column height */
- (CGFloat)digitHeight {
    return self.numberColumnSize.height * 0.1;
}

@end
