//
//  CSXPopSignatureView.h
//  CSXHandwrittenSignature
//
//  Created by 曹世鑫 on 2019/7/17.
//  Copyright © 2019 曹世鑫. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol  CSXPopSignatureViewDelegate <NSObject>

- (void)onSubmitBtn:(UIImage *_Nonnull)signatureImg;

@end


NS_ASSUME_NONNULL_BEGIN

@interface CSXPopSignatureView : UIView

@property (nonatomic, assign) id<CSXPopSignatureViewDelegate> delegate;

- (void)show;

- (void)hide;

@end

NS_ASSUME_NONNULL_END
