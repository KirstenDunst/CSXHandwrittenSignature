//
//  CSXSignatureView.h
//  CSXHandwrittenSignature
//
//  Created by 曹世鑫 on 2019/7/17.
//  Copyright © 2019 曹世鑫. All rights reserved.
//

#import <UIKit/UIKit.h>

//代理
@protocol CSXSignatureViewDelegate <NSObject>

/**
 获取截图图片
 
 @param image 手写绘制图
 */
@optional
- (void)getSignatureImg:(UIImage *_Nullable)image;

/**
 产生签名手写动作
 */
- (void)onSignatureWriteAction;

@end



NS_ASSUME_NONNULL_BEGIN

@interface CSXSignatureView : UIView 

@property (strong, nonatomic) NSString *showMessage; //签名完成后的水印文字
@property (nonatomic, assign) id<CSXSignatureViewDelegate> delegate;
@property (nonatomic, strong) UIImage *signatureImg;
@property (nonatomic, strong) NSMutableArray *currentPointArr;
@property (nonatomic, assign) BOOL hasSignatureImg;

/**
 清除
 */
- (void)clear;


/**
 确定
 */
- (void)sure;

@end

NS_ASSUME_NONNULL_END
