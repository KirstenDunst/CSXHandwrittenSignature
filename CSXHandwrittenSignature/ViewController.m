//
//  ViewController.m
//  CSXHandwrittenSignature
//
//  Created by 曹世鑫 on 2019/7/17.
//  Copyright © 2019 曹世鑫. All rights reserved.
//

#import "ViewController.h"
#import "CSXPopSignatureView.h"

@interface ViewController ()<CSXPopSignatureViewDelegate>
@property (nonatomic, strong)UIImageView *signImgView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIButton *chooseBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 44, [UIScreen mainScreen].bounds.size.width, 44)];
    [chooseBtn setTitle:@"提交" forState:UIControlStateNormal];
    [chooseBtn setTitleColor:[UIColor colorWithRed:255.0/255 green:255.0/255 blue:255.0/255 alpha:0.5] forState:UIControlStateNormal];
    chooseBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    chooseBtn.backgroundColor = [UIColor colorWithRed:0.1529 green:0.7765 blue:0.7765 alpha:1.0];
    [chooseBtn addTarget:self action:@selector(okAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:chooseBtn];
    
    [self.view addSubview:self.signImgView];
}

- (void)okAction {
    CSXPopSignatureView *socialSingnatureView = [CSXPopSignatureView new];
    socialSingnatureView.delegate = self;
    [socialSingnatureView show];
}

#pragma mark - SocialSignatureViewDelegate
- (void)onSubmitBtn:(UIImage *)signatureImg {
    self.signImgView.frame = CGRectMake(0, 90, signatureImg.size.width, signatureImg.size.height);
    self.signImgView.image = signatureImg;
}


#pragma mark - lazy
- (UIImageView *)signImgView {
    if (!_signImgView) {
        _signImgView = [[UIImageView alloc]initWithFrame:CGRectZero];
        _signImgView.backgroundColor = [UIColor cyanColor];
    }
    return _signImgView;
}

@end
