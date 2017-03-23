//
//  PAVOdometerView.h
//  Odometer
//
//  Created by Chris Paveglio on 3/19/17.
//  Copyright © 2017 Paveglio.com. All rights reserved.
//
// This class displays an accurate-to-life analog automobile odometer
// With the animation speed fudged for high number differential changing
// Layout is very size dependant- aspect ratio is not guaranteed. Self-expanding is not happening.
// This is ONLY for analog style odometer, digital counting (ie no animation) not supported.

#import <UIKit/UIKit.h>


@interface PAVOdometerView : UIView

/** The initial number to start the odometer at when view is shown */
@property (nonatomic, assign) NSUInteger startingNumber;

/** The number to scroll to, it could be less than the start number (differential can not be less than 0 */
@property (nonatomic, assign) NSUInteger endingNumber;

/** Number of digits/columns to display
 NOTE: This property will scale number columns as needed so the associated image assets
 should be size appropriately to fit in the space allotted
 */
@property (nonatomic, assign) NSUInteger numberOfDigits;

/** Number of seconds to do the animation */
@property (nonatomic, assign) CGFloat animationTime;

/** Image for the display of the numbers in a column */
@property (nonatomic, strong) UIImage *numberColumnImage;
/** Image to surround the odometer bezel */
@property (nonatomic, strong) UIImage *odometerFrameImage;

- (void)setupOdometerWithStartingNumber:(NSUInteger)startingNumber endingNumber:(NSUInteger)endingNumber numberOfDigits:(NSUInteger)numberOfDigits animationTime:(CGFloat)animationTime numberColumnImage:(UIImage *)numberColumnImage odometerFrameImage:(UIImage *)odometerFrameImage;

- (void)animateToNewNumber:(NSUInteger)newNumber;

@end
