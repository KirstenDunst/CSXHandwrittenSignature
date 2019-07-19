//
//  CSXPopSignatureView.m
//  CSXHandwrittenSignature
//
//  Created by 曹世鑫 on 2019/7/17.
//  Copyright © 2019 曹世鑫. All rights reserved.
//

#import "CSXPopSignatureView.h"
#import "CSXSignatureView.h"

#define ScreenWidth  [UIScreen mainScreen].bounds.size.width  //  设备的宽度
#define ScreenHeight [UIScreen mainScreen].bounds.size.height //   设备的高度
#define RGB(__R, __G, __B) [UIColor colorWithRed:(__R) / 255.0f green:(__G) / 255.0f blue:(__B) / 255.0f alpha:1.0]
#define WINDOW_COLOR  [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4]
#define SignatureViewHeight ((ScreenWidth*(350))/(375))

@interface CSXPopSignatureView () <CSXSignatureViewDelegate>
@property (nonatomic, strong) CSXSignatureView *signatureView;
@property (nonatomic, strong) UIButton *submitBtn;
@property (nonatomic, strong) UIButton *maskView;
@property (nonatomic, strong) UIView *backGroundView;

@end

@implementation CSXPopSignatureView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        [self setupView];
        
    }
    return self;
}

- (id)initWithMainView:(UIView*)mainView {
    self = [super init];
    if(self) {
        [self setupView];
    }
    return self;
}

- (void)showInView:(UIView *)view {
    [[UIApplication sharedApplication].delegate.window.rootViewController.view addSubview:self];
}

- (void)setupView {
    self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    self.backgroundColor = WINDOW_COLOR;
    self.userInteractionEnabled = YES;
    //蒙板背景
    [self addSubview:self.maskView];
    
    [UIView animateWithDuration:0.5 animations:^{
        [self.backGroundView setFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height-SignatureViewHeight, [UIScreen mainScreen].bounds.size.width, SignatureViewHeight)];
    } completion:^(BOOL finished) {
    }];
}

- (void)cancelAction {
    [self hide];
}

- (void)show {
    [UIView animateWithDuration:0.5 animations:^{
        UIWindow* window = [UIApplication sharedApplication].keyWindow;
        [window addSubview:self];
    }];
}

- (void)onSignatureWriteAction {
    [self.submitBtn setTitleColor:[UIColor colorWithRed:255.0/255 green:255.0/255 blue:255.0/255 alpha:1.0] forState:UIControlStateNormal];
}

- (void)hide {
    [UIView animateWithDuration:0.3 animations:^{
        [self.backGroundView setFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, SignatureViewHeight)];
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)onTapMaskView:(id)sender {
    [self hide];
}

//清除
- (void)onClear {
    [self.signatureView clear];
    [self.submitBtn setTitleColor:[UIColor colorWithRed:255.0/255 green:255.0/255 blue:255.0/255 alpha:0.5] forState:UIControlStateNormal];
}

- (void)okAction {
    [self.signatureView sure];
    if(self.signatureView.signatureImg) {
        NSLog(@"haveImage");
        self.hidden = YES;
        [self hide];
        if (self.delegate &&[self.delegate respondsToSelector:@selector(onSubmitBtn:)]) {
            [self.delegate onSubmitBtn:self.signatureView.signatureImg];
        }
    } else {
        NSLog(@"NoImage");
    }
}

#pragma mark - lazy
- (UIView *)maskView {
    if (!_maskView) {
        _maskView = [UIButton buttonWithType:UIButtonTypeCustom];
        _maskView.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
        _maskView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
        _maskView.userInteractionEnabled = YES;
        [_maskView addTarget:self action:@selector(onTapMaskView:) forControlEvents:UIControlEventTouchUpInside];
        //背景
        [_maskView addSubview:self.backGroundView];
    }
    return _maskView;
}
- (UIView *)backGroundView {
    if (!_backGroundView) {
        _backGroundView = [[UIView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, 0)];
        _backGroundView.backgroundColor = [UIColor whiteColor];
        _backGroundView.userInteractionEnabled = YES;
        UILabel *headView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 44)];
        headView.backgroundColor = [UIColor whiteColor];
        headView.textAlignment = NSTextAlignmentCenter;
        headView.textColor = [UIColor colorWithRed:0.3258 green:0.3258 blue:0.3258 alpha:1.0];
        headView.font = [UIFont systemFontOfSize:15];
        UIView *sepView1 = [[UIView alloc] initWithFrame:CGRectMake(0, 45, ScreenWidth, 1)];
        sepView1.backgroundColor = RGB(238, 238, 238);
        [_backGroundView addSubview:sepView1];
        headView.text = @"";
        [_backGroundView addSubview:headView];
        [_backGroundView addSubview:self.signatureView];
        
        UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(ScreenWidth - 50, 0, 44, 44)];
        [cancelBtn setTitle:@"清除" forState:UIControlStateNormal];
        [cancelBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        cancelBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [cancelBtn addTarget:self action:@selector(onClear) forControlEvents:UIControlEventTouchUpInside];
        [cancelBtn setTitleColor:[UIColor colorWithRed:155.0/255 green:155.0/255 blue:155.0/255 alpha:1.0]forState:UIControlStateNormal];
        [_backGroundView addSubview:cancelBtn];
        
        UIButton *signalBtn = [[UIButton alloc] initWithFrame:CGRectMake(6, 0, 44, 44)];
        [signalBtn setTitle:@"签名" forState:UIControlStateNormal];
        [signalBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        signalBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [signalBtn setTitleColor:[UIColor colorWithRed:51.0/255 green:51.0/255 blue:51.0/255 alpha:1.0]forState:UIControlStateNormal];
        [_backGroundView addSubview:signalBtn];
        
        [_backGroundView addSubview:self.submitBtn];
    }
    return _backGroundView;
}
- (CSXSignatureView *)signatureView {
    if (!_signatureView) {
        _signatureView = [[CSXSignatureView alloc] initWithFrame:CGRectMake(0,46, ScreenWidth, SignatureViewHeight - 44 - 44)];
        _signatureView.backgroundColor = [UIColor whiteColor];
        _signatureView.delegate = self;
        _signatureView.showMessage = @"";
    }
    return _signatureView;
}
- (UIButton *)submitBtn {
    if (!_submitBtn) {
        _submitBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, SignatureViewHeight-44, ScreenWidth, 44)];
        [_submitBtn setTitle:@"提交" forState:UIControlStateNormal];
        [_submitBtn setTitleColor:[UIColor colorWithRed:255.0/255 green:255.0/255 blue:255.0/255 alpha:0.5] forState:UIControlStateNormal];
        _submitBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        _submitBtn.backgroundColor = [UIColor colorWithRed:0.1529 green:0.7765 blue:0.7765 alpha:1.0];
        [_submitBtn addTarget:self action:@selector(okAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _submitBtn;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
