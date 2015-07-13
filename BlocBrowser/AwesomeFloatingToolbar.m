//
//  AwesomeFloatingToolbar.m
//  BlocBrowser
//
//  Created by Brian Douglas on 7/12/15.
//  Copyright (c) 2015 Bloc. All rights reserved.
//

#import "AwesomeFloatingToolbar.h"

@interface AwesomeFloatingToolbar ()

@property (nonatomic, strong) NSArray *currentTitles;
@property (nonatomic, strong) NSArray *colors;
@property (nonatomic, strong) NSArray *buttons;
@property (nonatomic, weak) UILabel *currentLabel;

@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, strong) UIPinchGestureRecognizer *pinchGesture;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGesture;

@end

@implementation AwesomeFloatingToolbar

-(instancetype) initWithFourTitles:(NSArray *)titles {
    self = [super init];
    
    if (self) {
        self.currentTitles = titles;
        self.colors = @[[UIColor colorWithRed:199/255.0 green:158/255.0 blue:203/255.0 alpha:1],
                       [UIColor colorWithRed:255/255.0 green:105/255.0 blue:97/255.0 alpha:1],
                       [UIColor colorWithRed:222/255.0 green:165/255.0 blue:164/255.0 alpha:1],
                       [UIColor colorWithRed:255/255.0 green:179/255.0 blue:71/255.0 alpha:1]];
        
        NSMutableArray *buttonsArray = [[NSMutableArray alloc] init];
        
        for (NSString *currentTitle in self.currentTitles) {
            UIButton *button = [[UIButton alloc] init];
            button.alpha = 0.25;
            
            NSUInteger currentTitleIndex = [self.currentTitles indexOfObject:currentTitle];
            NSString *titleForThisButton = [self.currentTitles objectAtIndex:currentTitleIndex];
            UIColor *colorForThisButton = [self.colors objectAtIndex:currentTitleIndex];
            
            button.titleLabel.textAlignment = NSTextAlignmentCenter;
            button.titleLabel.font = [UIFont systemFontOfSize:10];
            [button setTitle:titleForThisButton forState:UIControlStateNormal];
            
            button.backgroundColor = colorForThisButton;
            button.titleLabel.textColor = [UIColor whiteColor];
            button.enabled = NO;
            [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
            
            [buttonsArray addObject:button];
        }
        
        self.buttons = buttonsArray;
        
        for (UILabel *thisLabel in self.buttons) {
            [self addSubview:thisLabel];
        }
        

        // Gestures
        
        self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panFired:)];
        [self addGestureRecognizer:self.panGesture];
        self.pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchFired:)];
        [self addGestureRecognizer:self.pinchGesture];
        self.longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressFired:)];
        [self addGestureRecognizer:self.longPressGesture];
    }
    
    return self;
}

- (void) layoutSubviews {
    for (UILabel *thisLabel in self.buttons) {
        NSUInteger currentLabelIndex = [self.buttons indexOfObject:thisLabel];
        
        CGFloat labelHeight = CGRectGetHeight(self.bounds) / 2;
        CGFloat labelWidth = CGRectGetWidth(self.bounds) / 2;
        CGFloat labelX = 0;
        CGFloat labelY = 0;
        
        if (currentLabelIndex < 2) {
            labelY = 1;
        } else {
            labelY = CGRectGetHeight(self.bounds) / 2;
        }
        
        if (currentLabelIndex % 2 == 0) {
            labelX = 1;
        } else {
            labelX = CGRectGetWidth(self.bounds) / 2;
        }
        
        thisLabel.frame = CGRectMake(labelX, labelY, labelWidth, labelHeight);
    }
}

- (void) rotateLabelcolors {
    NSUInteger buttonsCount = self.buttons.count;
    NSMutableArray *newBackgroundColorArrangement = [NSMutableArray arrayWithCapacity:buttonsCount];
    // loop to change label colors
    for (NSUInteger i = 0; i < buttonsCount; i++) {
        if (i == (buttonsCount - 1)) {
            UIButton *btn = self.buttons[0];
            UIColor *color = btn.backgroundColor;
            newBackgroundColorArrangement[i] =color;
        } else {
            UIButton *btn = self.buttons[i + 1];
            UIColor *color = btn.backgroundColor;
            newBackgroundColorArrangement[i] = color;
        }
    }
    // apply those changes
    for (NSUInteger i = 0; i < buttonsCount; i++) {
        UIButton *btn = self.buttons[i];
        btn.backgroundColor = newBackgroundColorArrangement[i];
    }
}

#pragma mark - Gesture Handling

- (UILabel *) labelFromTouches:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    UIView *subview = [self hitTest:location withEvent:event];
    
    if ([subview isKindOfClass:[UILabel class]]) {
        return (UILabel *)subview;
    } else {
        return nil;
    }
}

- (void) panFired:(UIPanGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [recognizer translationInView:self];
        
        NSLog(@"New translation: %@", NSStringFromCGPoint(translation));
        
        if ([self.delegate respondsToSelector:@selector(floatingToolbar:didTryToPanWithOffset:)]) {
            [self.delegate floatingToolbar:self didTryToPanWithOffset:translation];
        }
        
        [recognizer setTranslation:CGPointZero inView:self];
    }
}

- (void) pinchFired:(UIPinchGestureRecognizer *)recognizer {

    if (recognizer.state == UIGestureRecognizerStateChanged) {
        NSLog(@"Pinched!");
        if ([self.delegate respondsToSelector:@selector(floatingToolbar:didTryToZoomWithScale:)]) {
            [self.delegate floatingToolbar:self didTryToZoomWithScale:recognizer];
        }

    }
}

- (void) longPressFired:(UILongPressGestureRecognizer *)recognizer {
    NSLog(@"Long Press!");
    if (recognizer.state == UIGestureRecognizerStateEnded) {
         NSLog(@"Long let go!");
        [self rotateLabelcolors];
    }
}

#pragma mark - Button Tapping

- (void)buttonTapped:(UIButton *)button {
    if ([self.delegate respondsToSelector:@selector(floatingToolbar:didSelectButtonWithTitle:)]) {
        [self.delegate floatingToolbar:self didSelectButtonWithTitle:button.titleLabel.text];
    }
}


- (void) setEnabled:(BOOL)enabled forButtonWithTitle:(NSString *)title {
    NSUInteger index = [self.currentTitles indexOfObject:title];
    
    if (index != NSNotFound) {
        UILabel *button = [self.buttons objectAtIndex:index];
        button.enabled = enabled;
        button.alpha = enabled ? 1.0 : 0.25;
    }
}

@end
