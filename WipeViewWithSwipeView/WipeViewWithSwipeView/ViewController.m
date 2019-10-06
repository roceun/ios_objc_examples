//
//  ViewController.m
//  WipeViewWithSwipeView
//
//  Created by ROCEUN on 07/10/2019.
//  Copyright © 2019 ROCEUN. All rights reserved.
//

#import "ViewController.h"
#import "SwipeView.h"

typedef NS_ENUM(NSInteger, Wipe_Transition_Direction) {
    Wipe_Transition_Direction_None,
    Wipe_Transition_Direction_Left,
    Wipe_Transition_Direction_Right
};

@interface ViewController () <SwipeViewDataSource, SwipeViewDelegate> {
	SwipeView *_swipeView;
	
	UIView *_transitionMaskView;
    
    UILabel *_transitionContentView;
    UILabel *_baseContentView;
    
    Wipe_Transition_Direction _direction;
	
	NSArray *_items;
	NSArray *_itemColors;
}

@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view.
	
	NSMutableArray *mutableArray = [NSMutableArray new];
	for (NSInteger index = 0; index < 3; index++) {
		[mutableArray addObject:[NSString stringWithFormat:@"Page %ld", index + 1]];
	}
	_items = mutableArray.copy;
	_itemColors = @[UIColor.yellowColor, UIColor.blueColor, UIColor.redColor];
	
	[self makeSubViews];
}

- (void)makeSubViews
{
	_baseContentView = [[UILabel alloc] initWithFrame:self.view.bounds];
	_baseContentView.textAlignment = NSTextAlignmentCenter;
	_baseContentView.font = [UIFont boldSystemFontOfSize:30.f];
	[self.view addSubview:_baseContentView];
	
	_transitionMaskView = [[UIView alloc] initWithFrame:self.view.bounds];
	_transitionMaskView.clipsToBounds = YES;
	[self.view addSubview:_transitionMaskView];
	
	_transitionContentView = [[UILabel alloc] initWithFrame:_transitionMaskView.bounds];
	_transitionContentView.textAlignment = NSTextAlignmentCenter;
	_transitionContentView.font = [UIFont boldSystemFontOfSize:30.f];
	[_transitionMaskView addSubview:_transitionContentView];
	
	_swipeView = [[SwipeView alloc] initWithFrame:self.view.bounds];
	_swipeView.dataSource = self;
	_swipeView.delegate = self;
	_swipeView.wrapEnabled = YES;
	_swipeView.pagingEnabled = YES;
	_swipeView.itemsPerPage = 1;
	_swipeView.alignment = SwipeViewAlignmentCenter;
	[self.view addSubview:_swipeView];
}

- (NSInteger)leftIndex:(NSInteger)index
{
    NSInteger leftIndex = index-1;
    if (leftIndex < 0) {
        leftIndex = _items.count - 1;
    }
    return leftIndex;
}

- (NSInteger)rightIndex:(NSInteger)index
{
    NSInteger rightIndex = index+1;
    if (_items.count <= rightIndex) {
        rightIndex = 0;
    }
    return rightIndex;
}

- (void)setTransitionMaskWidth:(CGFloat)width
{
	CGRect transitionFrame = _transitionMaskView.frame;
	transitionFrame.size.width = width;
    _transitionMaskView.frame = transitionFrame;
}

//MARK: - SwipeViewDataSource

- (NSInteger)numberOfItemsInSwipeView:(SwipeView *)swipeView
{
    return _items.count;
}

- (UIView *)swipeView:(SwipeView *)swipeView viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    view = [[UIView alloc] initWithFrame:self.view.bounds];
    
    if (index == [self leftIndex:_swipeView.currentItemIndex]) {
        _direction = Wipe_Transition_Direction_Left;
		
		_baseContentView.text = _items[[self rightIndex:index]];
		_baseContentView.backgroundColor = _itemColors[[self rightIndex:index]];
		_transitionContentView.text = _items[index];
		_transitionContentView.backgroundColor = _itemColors[index];
        
		[self setTransitionMaskWidth:0.f];
    } else if (index == [self rightIndex:_swipeView.currentItemIndex]) {
        _direction = Wipe_Transition_Direction_Right;
		
		_baseContentView.text = _items[index];
		_baseContentView.backgroundColor = _itemColors[index];
		_transitionContentView.text = _items[[self leftIndex:index]];
		_transitionContentView.backgroundColor = _itemColors[[self leftIndex:index]];
        
		[self setTransitionMaskWidth:_transitionContentView.frame.size.width];
    } else {
		_direction = Wipe_Transition_Direction_None;
		
		_transitionContentView.text = _items[index];
		_transitionContentView.backgroundColor = _itemColors[index];
		
		[self setTransitionMaskWidth:_transitionContentView.frame.size.width];
    }
	
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	button.tag = index;
	[button addTarget:self action:@selector(touchButton:) forControlEvents:UIControlEventTouchUpInside];
	button.frame = self.view.bounds;
	[view addSubview:button];
    
    return view;
}

//MARK: - SwipeViewDelegate

- (CGSize)swipeViewItemSize:(SwipeView *)swipeView
{
	return self.view.bounds.size;
}

- (void)swipeViewCurrentItemIndexDidChange:(SwipeView *)swipeView
{
    if (_direction == Wipe_Transition_Direction_Left) {
        _direction = Wipe_Transition_Direction_Right;
    } else if (_direction == Wipe_Transition_Direction_Right) {
        _direction = Wipe_Transition_Direction_Left;
        
		_baseContentView.text = _items[_swipeView.currentItemIndex];
		_baseContentView.backgroundColor = _itemColors[_swipeView.currentItemIndex];
		_transitionContentView.text = _items[[self leftIndex:_swipeView.currentItemIndex]];
		_transitionContentView.backgroundColor = _itemColors[[self leftIndex:_swipeView.currentItemIndex]];
    }
    
	CGRect transitionFrame = _transitionMaskView.frame;
	transitionFrame.size.width = _transitionContentView.frame.size.width / 2;
    _transitionMaskView.frame = transitionFrame;
}

- (void)swipeViewDidScroll:(SwipeView *)swipeView
{
    if (_direction == Wipe_Transition_Direction_Left) {
        UIView *view = [_swipeView itemViewAtIndex:[self leftIndex:_swipeView.currentItemIndex]];
        
        CGRect frame = view.frame;
        frame = [self.view convertRect:frame fromView:view.superview];
        
        if (frame.origin.x < -(_transitionMaskView.frame.size.width/2)) {
			[self setTransitionMaskWidth:MAX(0, _transitionContentView.frame.size.width + frame.origin.x)];
        }
    } else if (_direction == Wipe_Transition_Direction_Right) {
        UIView *view = [_swipeView itemViewAtIndex:_swipeView.currentItemIndex];
        
        CGRect frame = view.frame;
        frame = [self.view convertRect:frame fromView:view.superview];
        
		[self setTransitionMaskWidth:_transitionContentView.frame.size.width + frame.origin.x];
    }
}

//MARK: - Actions

- (void)touchButton:(UIButton *)button
{
	UIAlertController *alert = [UIAlertController
								alertControllerWithTitle:@"WipeView"
								message:_items[button.tag]
								preferredStyle:UIAlertControllerStyleAlert];
	
	UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"OK"
													  style:UIAlertActionStyleDefault
													handler:^(UIAlertAction * action) {
		[alert dismissViewControllerAnimated:YES completion:nil];
	}];
	[alert addAction:confirm];
	[self presentViewController:alert animated:YES completion:nil];
}

@end
