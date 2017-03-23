//
//  PAVOdometerView.m
//  Odometer
//
//  Created by Chris Paveglio on 3/19/17.
//  Copyright © 2017 Paveglio.com. All rights reserved.
//

#import "PAVOdometerView.h"

#define KDefaultNumberOfDigits 10
#define KDefaultAnimationTime 3.0

@interface PAVOdometerView ()

@property (nonatomic, assign) BOOL countingUpwards;

@property (nonatomic, strong) NSArray *dialNumbers;

@end


@implementation PAVOdometerView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        
    }
    return self;
}

- (void)setupOdometerWithStartingNumber:(NSUInteger)startingNumber endingNumber:(NSUInteger)endingNumber numberOfDigits:(NSUInteger)numberOfDigits animationTime:(CGFloat)animationTime numberColumnImage:(UIImage *)numberColumnImage odometerFrameImage:(UIImage *)odometerFrameImage {
    
    _startingNumber = startingNumber;
    _endingNumber = endingNumber;
    _numberOfDigits = numberOfDigits > 0 ? numberOfDigits : KDefaultNumberOfDigits;
    _animationTime = animationTime ? : KDefaultAnimationTime;
    _numberColumnImage = numberColumnImage;
    _odometerFrameImage = odometerFrameImage;
    
    self.countingUpwards = endingNumber > startingNumber;

    NSString *biggerNumberString = [NSString stringWithFormat:@"%ld", (endingNumber > startingNumber) ? endingNumber : startingNumber];
    NSUInteger numberLength = biggerNumberString.length;
    _numberOfDigits = numberOfDigits > numberLength ? numberOfDigits : numberLength;
    
    if (odometerFrameImage) {
        UIImageView *bezelImageView = [[UIImageView alloc] initWithImage:self.odometerFrameImage];
        [bezelImageView setContentMode:UIViewContentModeScaleToFill];
        [self addSubview:bezelImageView];
        [self.leftAnchor constraintEqualToAnchor:bezelImageView.leftAnchor].active = YES;
        [self.topAnchor constraintEqualToAnchor:bezelImageView.topAnchor].active = YES;
        [self.rightAnchor constraintEqualToAnchor:bezelImageView.rightAnchor].active = YES;
        [self.bottomAnchor constraintEqualToAnchor:bezelImageView.bottomAnchor].active = YES;
    }
    
    [self createOdometerColumnsWithStartingNumber];
}

- (void)createOdometerColumnsWithStartingNumber {
    //iterate on # of digits to make number column UIImageViews
    //set the size of the column views to be appropriate for the # of rows for view frame size
    NSMutableArray *setup = [NSMutableArray arrayWithCapacity:self.numberOfDigits];
    CGFloat columnWidth = self.frame.size.width / (CGFloat)self.numberOfDigits;
    CGFloat columnHeight = columnWidth * 10.0;
    for (int i = 0; i < self.numberOfDigits; i++) {
        //set up the rows at indexes from 0 to X, with 0 on RIGHT as the 1's column
        CGFloat xOffset = self.frame.size.width - ((i + 1) * columnWidth);
        CGRect columnSize = CGRectMake(xOffset, 0, columnWidth, columnHeight);
        UIImageView *columnView = [[UIImageView alloc] initWithFrame:columnSize];
        [columnView setContentMode:UIViewContentModeScaleToFill];
        [columnView setImage:self.numberColumnImage];
        [setup addObject:columnView];
    }
    
    //get the digit offset for the column
    //adjust the frame origin for the # to display in the column
    self.dialNumbers = (NSArray *)setup;
    NSArray *digitsArray = [self digitsForNumber:self.endingNumber reversed:YES];
    for (int i = 0; i < self.dialNumbers.count; i++) {
        UIImageView *aView = self.dialNumbers[i];
        CGRect imageRect = aView.frame;
        imageRect.origin.y = -1 * [(NSNumber *)digitsArray[i] floatValue] * [self calculateDigitHeight:aView];
        [aView setFrame:imageRect];
        [self addSubview:aView];
    }
}

- (void)animateToNewNumber:(NSUInteger)newNumber {
    self.endingNumber = newNumber;
    [UIView animateKeyframesWithDuration:self.animationTime delay:0.0 options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{

        NSUInteger differential = self.endingNumber - self.startingNumber;
        NSArray *digitsArray = [self digitsForNumber:differential reversed:YES];
        NSArray *startDigits = [self digitsForNumber:self.startingNumber reversed:YES];
        int j = (int)digitsArray.count;
        
        for (int i = 0; i < 1; i++) {
            
            //start an animation from current offset to 9 (end)
            CGFloat rounded = (CGFloat)differential / (10 ^ i);
            NSString *stringTruncated = [NSString stringWithFormat:@"%.1f", rounded];
            CGFloat truncated = [stringTruncated floatValue];
            
            CGFloat preCompleteRotatesOffset = (10.0 - [(NSNumber *)startDigits[i] floatValue]) / 10.0;
            
            CGFloat rotatesLessPreRotates = truncated - preCompleteRotatesOffset;
            
            CGFloat completeRotates = floorf(rotatesLessPreRotates);
            
            CGFloat afterCompleteRotatesOffset = [(NSNumber *)digitsArray[i] floatValue] / 10.0;
            
            
            //add a keyframe to go from current value to 9
            //add a keyframe to repeat X times
            //add a keyframe to go from 0 to new offset
            
            //divide time into XXX segments based on differential number
            //animationTime / differential = milliseconds per action
            //multiply pre-action number * millis
            //multiply repeating action * millis / 10
            //multiply post action number * millis
            
            
            //move counter from position to max
            NSUInteger digit = [(NSNumber *)digitsArray[i] floatValue];
            UIImageView *thisView = self.dialNumbers[i];
            
            [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:0.1 animations:^{
                UIImageView *aView = self.dialNumbers[i];
                CGAffineTransform move = CGAffineTransformMakeTranslation(0, preCompleteRotatesOffset * -thisView.frame.size.height);
                [aView setTransform:move];
            }];
            
            [UIView addKeyframeWithRelativeStartTime:0.1 relativeDuration:0.0 animations:^{
                UIImageView *aView = self.dialNumbers[i];
                CGAffineTransform move = CGAffineTransformMakeTranslation(0, 0);
                [aView setTransform:move];
            }];
            
            [UIView addKeyframeWithRelativeStartTime:0.1 relativeDuration:0.8 animations:^{
                UIImageView *aView = self.dialNumbers[i];
                CGAffineTransform move = CGAffineTransformMakeTranslation(0, -thisView.frame.size.height);
                [aView setTransform:move];
            }];
            
            [UIView addKeyframeWithRelativeStartTime:0.9 relativeDuration:0.0 animations:^{
                UIImageView *aView = self.dialNumbers[i];
                CGAffineTransform move = CGAffineTransformMakeTranslation(0, 0);
                [aView setTransform:move];
            }];
            
            [UIView addKeyframeWithRelativeStartTime:0.9 relativeDuration:0.1 animations:^{
                UIImageView *aView = self.dialNumbers[i];
                CGAffineTransform move = CGAffineTransformMakeTranslation(0, afterCompleteRotatesOffset * -thisView.frame.size.height);
                [aView setTransform:move];
            }];
        }
        
        
        
        
        
//            [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:0.5 animations:^{
//                UIImageView *aView = self.dialNumbers[0];
//                CGAffineTransform move = CGAffineTransformMakeTranslation(0, -300);
//                [aView setTransform:move];
//            }];
//            [UIView addKeyframeWithRelativeStartTime:0.5 relativeDuration:0.5 animations:^{
//                UIImageView *aView = self.dialNumbers[0];
//                CGAffineTransform move = CGAffineTransformMakeTranslation(0, 100);
//                [aView setTransform:move];
//            }];
//            
//            [UIView addKeyframeWithRelativeStartTime:0.2 relativeDuration:0.5 animations:^{
//                UIImageView *aView = self.dialNumbers[1];
//                CGAffineTransform move = CGAffineTransformMakeTranslation(0, 100);
//                [aView setTransform:move];
//            }];
//            [UIView addKeyframeWithRelativeStartTime:0.7 relativeDuration:0.3 animations:^{
//                UIImageView *aView = self.dialNumbers[1];
//                CGAffineTransform move = CGAffineTransformMakeTranslation(0, 300);
//                [aView setTransform:move];
//            }];


    } completion:^(BOOL finished) {
        NSLog(@" transform done");
    }];
}




- (CGFloat)calculateDigitHeight:(UIImageView *)numberColumnView {
    return numberColumnView.frame.size.height * 0.1;
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
        numberString = [self reverseString:numberString];
    }
    NSMutableArray *digitArray = [NSMutableArray array];
    for (int i = 0; i < numberString.length; i++) {
        NSString *digitString = [numberString substringWithRange:NSMakeRange(i, 1)];
        [digitArray addObject:@([digitString integerValue])];
    }
    return digitArray;
}

/** Reverses a given string */
- (NSString *)reverseString:(NSString *)string {
    NSString *reverseString = [NSString new];
    for (NSInteger i = string.length - 1; i > -1; i--) {
        reverseString = [reverseString stringByAppendingFormat:@"%c", [string characterAtIndex:i]];
    }
    return reverseString;
}

@end





