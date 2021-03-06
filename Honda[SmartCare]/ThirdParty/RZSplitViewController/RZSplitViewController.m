//
//  RZSplitViewController.m
//
//  Created by Joe Goullaud on 8/6/12.

// Copyright 2014 Raizlabs and other contributors
// http://raizlabs.com/
//
// Permission is hereby granted, free of charge, to any person obtaining
// a copy of this software and associated documentation files (the
// "Software"), to deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so, subject to
// the following conditions:
//
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
// LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
// WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import <QuartzCore/QuartzCore.h>
#import "RZSplitViewController.h"

#define kRZSplitViewMasterIndex 0
#define kRZSplitViewDetailIndex 1
//#define kHamburgerChar @"≡"
#define kHamburgerChar @" "


@interface RZSplitViewController () <UINavigationControllerDelegate>

@property (strong, nonatomic, readwrite) UIBarButtonItem *collapseBarButton;
@property (nonatomic, assign) BOOL usingCustomMasterWidth;

- (void)initializeSplitViewController;

- (void)layoutViewControllers;
- (void)layoutViewsForCollapsed:(BOOL)collapsed animated:(BOOL)animated;

- (void)configureCollapseButton:(UIBarButtonItem*)collapseButton forCollapsed:(BOOL)collapsed;

//- (void)collapseBarButtonTapped:(id)sender;

@end

#define RZSPLITVIEWCONTROLLER_DEFAULT_MASTER_WIDTH 320.0
#define RZSPLITVIEWCONTROLLER_DEFAULT_CORNER_RADIUS 4.0f
#define RZSPLITVIEWCONTROLLER_DEFAULT_BORDER_WIDTH 1.0f

@implementation RZSplitViewController
@synthesize viewControllers = _viewControllers;
@synthesize delegate = _delegate;
@synthesize collapseBarButtonImage = _collapseBarButtonImage;
@synthesize expandBarButtonImage = _expandBarButtonImage;
@synthesize collapseBarButton = _collapseBarButton;
@synthesize collapsed = _collapsed;
@synthesize viewBorderColor = _viewBorderColor;
@synthesize viewBorderWidth = _viewBorderWidth;
@synthesize viewCornerRadius = _viewCornerRadius;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.usingCustomMasterWidth = NO;
        [self initializeSplitViewController];
//       / ASDisplayNode *webviewNode = [[ASDisplayNode alloc] initWithViewClass:[UIWebView class]];
    }
    return self;
}

- (void)awakeFromNib
{
    [self initializeSplitViewController];
}

- (void)setMasterWidth:(CGFloat)masterWidth
{
    self.usingCustomMasterWidth = YES;
    _masterWidth = masterWidth;
}

- (void)initializeSplitViewController
{
   // self.detailViewController.view.layer.sh
    self.viewCornerRadius = RZSPLITVIEWCONTROLLER_DEFAULT_CORNER_RADIUS;
    self.viewBorderWidth = RZSPLITVIEWCONTROLLER_DEFAULT_BORDER_WIDTH;
    self.viewBorderColor = [UIColor blackColor];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blackColor];
    [self layoutViewControllers];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self layoutViewsForCollapsed:self.collapsed animated:NO];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma mark - Property Accessor Overrides

- (UIViewController*)masterViewController
{
    return [self.viewControllers objectAtIndex:kRZSplitViewMasterIndex];
}

- (UIViewController*)detailViewController
{
    return [self.viewControllers objectAtIndex:kRZSplitViewDetailIndex];
}

- (void)setViewControllers:(NSArray *)viewControllers
{
    NSAssert(2 == [viewControllers count], @"You must have exactly 2 view controllers in the array. This array has %lu.", (long)[viewControllers count]);
    
    [_viewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIViewController *vc = (UIViewController*)obj;
        
        [vc willMoveToParentViewController:nil];
        [vc.view removeFromSuperview];
        [vc removeFromParentViewController];
    }];
    
    _viewControllers = [viewControllers copy];
    
    [_viewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIViewController *vc = (UIViewController*)obj;
        
        [self addChildViewController:vc];
        [vc didMoveToParentViewController:self];
    }];
    
    [self layoutViewControllers];
}

- (void)setCollapseBarButtonImage:(UIImage *)collapseBarButtonImage
{
    _collapseBarButtonImage = collapseBarButtonImage;
    
    if (!self.collapsed)
    {
        [_collapseBarButton setImage:_collapseBarButtonImage];
    }
}
- (void)setImageForCollapseBarButton:(UIImage *)collapseBarButtonImage
{
    [_collapseBarButton setImage:collapseBarButtonImage];
}

- (void)setExpandBarButtonImage:(UIImage *)expandBarButtonImage
{
    _expandBarButtonImage = expandBarButtonImage;
    
    if (self.collapsed)
    {
        [_collapseBarButton setImage:_expandBarButtonImage];
    }
}

- (void)setDetailViewController:(UIViewController*)detailVC
{
    NSAssert(detailVC != nil, @"The detail view controller must not be nil");
    
    if (detailVC)
    {
        NSMutableArray* updatedViewControllers = [[self viewControllers] mutableCopy];
        [updatedViewControllers setObject:detailVC atIndexedSubscript:kRZSplitViewDetailIndex];
        [self setViewControllers:updatedViewControllers];
    }
}

- (void)setMasterViewController:(UIViewController*)masterVC
{
    NSAssert(masterVC != nil, @"The master view controller must not be nil");
    
    if (masterVC)
    {
        NSMutableArray* updatedViewControllers = [[self viewControllers] mutableCopy];
        [updatedViewControllers setObject:masterVC atIndexedSubscript:kRZSplitViewMasterIndex];
        [self setViewControllers:updatedViewControllers];
    }
}

- (UIBarButtonItem*)collapseBarButton
{
    if (nil == _collapseBarButton)
    {
        _collapseBarButton = [[UIBarButtonItem alloc] initWithTitle:(self.collapsed ? kHamburgerChar : kHamburgerChar) style:UIBarButtonItemStylePlain target:self action:@selector(collapseBarButtonTapped:)];
        
        [self configureCollapseButton:_collapseBarButton forCollapsed:self.collapsed];
    }
    
    return _collapseBarButton;
}

- (void)setCollapsed:(BOOL)collapsed
{
    [self setCollapsed:collapsed animated:NO];
}

- (void)setCollapsed:(BOOL)collapsed animated:(BOOL)animated
{
//    if (collapsed == _collapsed)
//    {
//        return;
//    }
    
    _collapsed = collapsed;
    [self layoutViewsForCollapsed:collapsed animated:animated];
}

#pragma mark - Private Property Accessor Overrides

#pragma mark - View Controller Layout

- (void)layoutViewControllers
{
    UIViewController *masterVC = [self.viewControllers objectAtIndex:kRZSplitViewMasterIndex];
    UIViewController *detailVC = [self.viewControllers objectAtIndex:kRZSplitViewDetailIndex];
    
    UIViewAutoresizing masterAutoResizing = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
    UIViewAutoresizing detailAutoResizing = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    masterVC.view.contentMode = UIViewContentModeScaleToFill;
    masterVC.view.autoresizingMask = masterAutoResizing;
    masterVC.view.autoresizesSubviews = YES;
    masterVC.view.clipsToBounds = YES;
    
    masterVC.view.layer.borderWidth = self.viewBorderWidth;
    masterVC.view.layer.borderColor = [self.viewBorderColor CGColor];
    masterVC.view.layer.cornerRadius = self.viewCornerRadius;
    
    detailVC.view.contentMode = UIViewContentModeScaleToFill;
    detailVC.view.autoresizingMask = detailAutoResizing;
    detailVC.view.autoresizesSubviews = YES;
    detailVC.view.clipsToBounds = YES;
    
    detailVC.view.layer.borderWidth = self.viewBorderWidth;
    detailVC.view.layer.borderColor = [self.viewBorderColor CGColor];
    detailVC.view.layer.cornerRadius = self.viewCornerRadius;
    
    [self.view addSubview:masterVC.view];
    [self.view addSubview:detailVC.view];
    
    [self layoutViewsForCollapsed:self.collapsed animated:NO];
}
//
- (void)handlePanGestureRecognizer:(UIPanGestureRecognizer*)gesture inViewController:(UIViewController*)viewController completionBlock:(void (^)(BOOL collapse))completionBlock {
    UIViewController *masterVC;
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan: {
            
            masterVC = [self.viewControllers objectAtIndex:0];
            masterViewBaseFrame = masterVC.view.frame;
            touchBeganPoint = [gesture locationInView:viewController.view];
            backupConstraint = [self.detailViewController.view constraints];
            [self.detailViewController.view removeConstraints:self.detailViewController.view.constraints];
            break;
        }
        case UIGestureRecognizerStateChanged: {
            viewController.view.userInteractionEnabled = NO;
            
            CGPoint translatedPoint = [gesture translationInView:viewController.view];
            // finger width is 44 :D. This code must be reconsidered
            if (self.collapsed && touchBeganPoint.x <= 44) {
                [self layoutViewsForPanGestureWithLocation:translatedPoint.x + CGRectGetMinX(masterViewBaseFrame)];
            } else if ([gesture locationInView:viewController.view].x <= 44 && translatedPoint.x < 0) {
                if (touchBeganPoint.x <= 44) {
                    [self layoutViewsForPanGestureWithLocation:translatedPoint.x + CGRectGetMinX(masterViewBaseFrame)];
                } else {
                    [self layoutViewsForPanGestureWithLocation:translatedPoint.x + CGRectGetMinX(masterViewBaseFrame) + touchBeganPoint.x + 44];
                }
                //[self layoutViewsForPanGestureWithLocation:translatedPoint.x + CGRectGetMinX(masterViewBaseFrame)];
            }
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled: {
            viewController.view.userInteractionEnabled = YES;
            if (touchBeganPoint.x > 44 && [gesture translationInView:viewController.view].x > 0) {
                // do nothing when swipe from inside view to the right
                break;
            }
            BOOL isCollapsed;
            CGFloat midX  = CGRectGetMidX(masterViewBaseFrame) > 0 ? CGRectGetMidX(masterViewBaseFrame) :CGRectGetWidth(masterViewBaseFrame) / 2;
            NSLog(@"MIDXXX :%f",midX);
            if ([gesture locationInView:self.view].x > midX) {
                isCollapsed = [gesture translationInView:viewController.view].x > 0 ? NO:self.isCollapsed;
            } else {
                isCollapsed = [gesture translationInView:viewController.view].x > 0 ? self.isCollapsed:YES;
            }
            NSLog(@"gesture :%f",[gesture translationInView:viewController.view].x);
            completionBlock(isCollapsed);
            [self setCollapsed:isCollapsed animated:YES];
            [self configureCollapseButton:_collapseBarButton forCollapsed:isCollapsed];
            break;
        }
            
        default:
            break;
    }
}
- (void)layoutViewsForPanGestureWithLocation:(CGFloat)xLocation {
    UIViewController *masterVC = self.masterViewController;
    UIViewController *detailVC = self.detailViewController;
    CGRect viewBounds = self.view.bounds;
    CGFloat masterWidth = self.usingCustomMasterWidth ? self.masterWidth : RZSPLITVIEWCONTROLLER_DEFAULT_MASTER_WIDTH;
    
    if (ABS(xLocation) <= masterWidth) {
        if (masterVC.view.superview != self.view) {
            [self.view addSubview:masterVC.view];
        }
        if (xLocation <= 0) {
            
            // over draw
//            CGRect masterFrame = CGRectMake(xLocation / 4, 0, masterWidth, viewBounds.size.height);
//            CGFloat detailLocation = detailVC.view.frame.origin.x;
//            CGRect detailFrame = CGRectMake(CGRectGetMaxX(masterViewBaseFrame) + xLocation - CGRectGetMinX(masterViewBaseFrame), 0, viewBounds.size.width - masterFrame.size.width + (-1 * xLocation), viewBounds.size.height);
            
            // side by side
            CGRect masterFrame = CGRectMake(xLocation, 0, masterWidth, viewBounds.size.height);
            CGRect detailFrame = CGRectMake(CGRectGetMaxX(masterFrame), 0, viewBounds.size.width + (-1 * xLocation) - CGRectGetWidth(masterFrame), viewBounds.size.height);
            masterVC.view.frame = masterFrame;
            detailVC.view.frame = detailFrame;
        } else {
            //[self layoutViewsForCollapsed:NO animated:YES];
        }
    
    } else {
        //[self layoutViewsForCollapsed:YES animated:YES];
    }
}

- (void)layoutViewsForCollapsed:(BOOL)collapsed animated:(BOOL)animated
{
    void (^layoutBlock)(void);
    void (^completionBlock)(BOOL finished);
    
    UIViewController *masterVC = [self.viewControllers objectAtIndex:0];
    UIViewController *detailVC = [self.viewControllers objectAtIndex:1];
    
    CGRect viewBounds = self.view.bounds;
    CGFloat masterWidth = self.usingCustomMasterWidth ? self.masterWidth : RZSPLITVIEWCONTROLLER_DEFAULT_MASTER_WIDTH;
    
    if (collapsed)
    {
        layoutBlock = ^(void){
            CGRect masterFrame = CGRectMake(-masterWidth, 0, masterWidth+1.0, viewBounds.size.height);
            CGRect detailFrame = CGRectMake(0, 0, viewBounds.size.width, viewBounds.size.height);
            
            masterVC.view.frame = masterFrame;
            detailVC.view.frame = detailFrame;
        };
        
        completionBlock = ^(BOOL finished){
            //[masterVC.view removeFromSuperview];
        };
    }
    else
    {
        if (masterVC.view.superview != self.view)
        {
            [self.view addSubview:masterVC.view];
        }
        layoutBlock = ^(void){
            CGRect masterFrame = CGRectMake(0, 0, masterWidth+0.0, viewBounds.size.height);
            CGRect detailFrame = CGRectMake(masterWidth, 0, viewBounds.size.width - (masterWidth ), viewBounds.size.height);
            
            masterVC.view.frame = masterFrame;
            detailVC.view.frame = detailFrame;
        };
        
        completionBlock = ^(BOOL finished){
            
        };
    }
    
    if (animated)
    {
        [UIView animateWithDuration:0.25
                              delay:0
                            options:UIViewAnimationOptionLayoutSubviews
                         animations:layoutBlock
                         completion:completionBlock];
    }
    else
    {
        layoutBlock();
        completionBlock(YES);
    }
}

- (void)configureCollapseButton:(UIBarButtonItem*)collapseButton forCollapsed:(BOOL)collapsed
{
    if (collapsed)
    {
        if (self.expandBarButtonImage)
        {
            [collapseButton setImage:self.expandBarButtonImage];
        }
        else if (self.collapseBarButtonImage)
        {
            [collapseButton setImage:self.collapseBarButtonImage];
        }
        else
        {
            [collapseButton setTitle:kHamburgerChar];
        }
    }
    else
    {
        if (self.collapseBarButtonImage)
        {
            [collapseButton setImage:self.collapseBarButtonImage];
        }
        else
        {
            [collapseButton setTitle:kHamburgerChar];
        }
    }
}

#pragma mark - Action Methods

- (void)collapseBarButtonTapped:(id)sender
{
    BOOL collapsed = !self.collapsed;
    
    UIBarButtonItem *buttonItem = (UIBarButtonItem*)sender;
    
    [self configureCollapseButton:buttonItem forCollapsed:collapsed];
    
    [self setCollapsed:collapsed animated:YES];
    // Add action when tap on Collapse Bar Button
    if (self.collapseBarButtonTappedBlock) {
        self.collapseBarButtonTappedBlock();
    }
}

@end


@implementation UIViewController (RZSplitViewController)

- (RZSplitViewController*)rzSplitViewController
{
    if (self.parentViewController)
    {
        if ([self.parentViewController isKindOfClass:[RZSplitViewController class]])
        {
            return (RZSplitViewController*)self.parentViewController;
        }
        else
        {
            return [self.parentViewController rzSplitViewController];
        }
    }

    return nil;
}

@end
