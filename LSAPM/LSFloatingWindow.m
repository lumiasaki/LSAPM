//
//  LSFloatingWindow.m
//  LSAPM
//
//  Created by tianren.zhu on 2017/4/28.
//  Copyright © 2017年 tianren.zhu. All rights reserved.
//

#import "LSFloatingWindow.h"

static const CGFloat SINGLE_HEIGHT = 15;
static const CGFloat SINGLE_WIDTH = 70;
static const CGRect FLOATING_WINDOW_SIZE = {0, 0, SINGLE_WIDTH, 3 * SINGLE_HEIGHT};

@interface LSFloatingWindowSingleDisplayComponent : UIView

@property (nonatomic, strong) NSNumber *value;
@property (nonatomic, strong, readonly) NSString *title;

- (instancetype)initWithTitle:(NSString *)title;

@end

static const CGRect FLOATING_WINDOW_SINGLE_COMPONENT_SIZE = {0, 0, SINGLE_WIDTH, SINGLE_HEIGHT};
static const CGFloat TITLE_LABEL_WIDTH = 30;
static const CGFloat VALUE_LABEL_WIDTH = SINGLE_WIDTH - TITLE_LABEL_WIDTH;

@interface LSFloatingWindowSingleDisplayComponent ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *valueLabel;
@property (nonatomic, strong) NSNumberFormatter *formatter;

@end

@implementation LSFloatingWindowSingleDisplayComponent

- (instancetype)initWithTitle:(NSString *)title {
    if (self = [super initWithFrame:FLOATING_WINDOW_SINGLE_COMPONENT_SIZE]) {
        _title = title;
        
        [self initAndLayout];
    }
    
    return self;
}

- (void)initAndLayout {
    self.titleLabel.frame = CGRectMake(0, 0, TITLE_LABEL_WIDTH, SINGLE_HEIGHT);
    self.valueLabel.frame = CGRectMake(TITLE_LABEL_WIDTH, 0, VALUE_LABEL_WIDTH, SINGLE_HEIGHT);
    
    [self addSubview:self.titleLabel];
    [self addSubview:self.valueLabel];
}

#pragma mark - Setter

- (void)setValue:(NSNumber *)value {
    _value = value;
    
    self.valueLabel.text = [self.formatter stringFromNumber:value];
}

#pragma mark - Getter

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.text = [NSString stringWithFormat:@"%@: ", self.title];
        _titleLabel.font = [UIFont systemFontOfSize:10];
    }
    
    return _titleLabel;
}

- (UILabel *)valueLabel {
    if (!_valueLabel) {
        _valueLabel = [[UILabel alloc] init];
        _valueLabel.font = [UIFont systemFontOfSize:10];
    }
    
    return _valueLabel;
}

- (NSNumberFormatter *)formatter {
    if (!_formatter) {
        _formatter = [[NSNumberFormatter alloc] init];
        _formatter.maximumFractionDigits = 3;
        _formatter.minimumIntegerDigits = 1;
    }
    
    return _formatter;
}

@end

@interface LSFloatingWindow ()

@property (nonatomic, strong) LSFloatingWindowSingleDisplayComponent *fpsDisplay;
@property (nonatomic, strong) LSFloatingWindowSingleDisplayComponent *memoryDisplay;
@property (nonatomic, strong) LSFloatingWindowSingleDisplayComponent *cpuDisplay;

@property (nonatomic, strong) UIPanGestureRecognizer *gestureRecognizer;

@end

@implementation LSFloatingWindow

- (instancetype)init {
    if (self = [super initWithFrame:FLOATING_WINDOW_SIZE]) {
        _fps = @0;
        _memory = @0;
        _cpu = @0;
        
        [self initAndLayout];
    }
    
    return self;
}

- (void)initAndLayout {
    void(^adjustDisplaysOriginY)(NSArray *) = ^void(NSArray *displays) {
        
        NSUInteger i = 0;
        for (LSFloatingWindowSingleDisplayComponent *displayComponent in displays) {
            CGRect originalFrame = displayComponent.frame;
            
            originalFrame.origin.y = SINGLE_HEIGHT * i;
            
            displayComponent.frame = originalFrame;
            
            i += 1;
        }
    };
    
    adjustDisplaysOriginY(@[self.fpsDisplay, self.memoryDisplay, self.cpuDisplay]);
    
    [self addGestureRecognizer:self.gestureRecognizer];
    
    [self addSubview:self.fpsDisplay];
    [self addSubview:self.memoryDisplay];
    [self addSubview:self.cpuDisplay];
    
    self.backgroundColor = UIColor.lightGrayColor;
}

- (void)anrOccurred:(NSString *)stacktrace {
    self.backgroundColor = UIColor.redColor;
}

#pragma mark - Private

- (void)gestureRecognized:(UIPanGestureRecognizer *)gestureRecognizer {
    CGPoint translation = [gestureRecognizer translationInView:self];
    gestureRecognizer.view.center = CGPointMake(gestureRecognizer.view.center.x + translation.x, gestureRecognizer.view.center.y + translation.y);
    
    [gestureRecognizer setTranslation:CGPointZero inView:self];
}

#pragma mark - Setter

- (void)setFps:(NSNumber *)fps {
    _fps = fps;
    
    self.fpsDisplay.value = fps;
}

- (void)setMemory:(NSNumber *)memory {
    _memory = memory;
    
    self.memoryDisplay.value = memory;
}

- (void)setCpu:(NSNumber *)cpu {
    _cpu = cpu;
    
    self.cpuDisplay.value = cpu;
}

#pragma mark - Getter

- (LSFloatingWindowSingleDisplayComponent *)fpsDisplay {
    if (!_fpsDisplay) {
        _fpsDisplay = [[LSFloatingWindowSingleDisplayComponent alloc] initWithTitle:@"fps"];
    }
    
    return _fpsDisplay;
}

- (LSFloatingWindowSingleDisplayComponent *)memoryDisplay {
    if (!_memoryDisplay) {
        _memoryDisplay = [[LSFloatingWindowSingleDisplayComponent alloc] initWithTitle:@"mem"];
    }
    
    return _memoryDisplay;
}

- (LSFloatingWindowSingleDisplayComponent *)cpuDisplay {
    if (!_cpuDisplay) {
        _cpuDisplay = [[LSFloatingWindowSingleDisplayComponent alloc] initWithTitle:@"cpu"];
    }
    
    return _cpuDisplay;
}

- (UIPanGestureRecognizer *)gestureRecognizer {
    if (!_gestureRecognizer) {
        _gestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(gestureRecognized:)];
    }
    
    return _gestureRecognizer;
}

@end
