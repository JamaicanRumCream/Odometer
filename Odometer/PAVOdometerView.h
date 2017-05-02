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
@class PAVOdometerView;


@protocol pavOdometerViewDelegate <NSObject>

@optional
- (void)pavOdometerView:(PAVOdometerView *)odometerView didCompleteWithIdentifier:(NSString *)identifier;

@end


@interface PAVOdometerView : UIView

@property (nonatomic, strong) id<pavOdometerViewDelegate> delegate;

/** Image for the display of the numbers in a column */
@property (nonatomic, strong) UIImage *numberColumnImage;
/** Image to surround the odometer bezel */
@property (nonatomic, strong) UIImage *odometerFrameImage;

/** Initializes the view with the starting number, b/c you don't always want to start at 0 */
- (void)setupOdometerWithStartingNumber:(NSUInteger)startingNumber numberColumnImage:(UIImage *)numberColumnImage odometerFrameImage:(UIImage *)odometerFrameImage;

/** Animates to the new number, as long as it is higher than current number */
- (void)animateToNumber:(NSUInteger)newNumber animationTime:(CGFloat)animationTime;

/** Animates to the new number, as long as it is higher than current number, and returns with the given identifier */
- (void)animateToNumber:(NSUInteger)newNumber animationTime:(CGFloat)animationTime identifier:(NSString *)idenfifier;

@end
