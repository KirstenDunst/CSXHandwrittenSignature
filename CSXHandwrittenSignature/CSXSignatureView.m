//
//  CSXSignatureView.m
//  CSXHandwrittenSignature
//
//  Created by 曹世鑫 on 2019/7/17.
//  Copyright © 2019 曹世鑫. All rights reserved.
//

#import "CSXSignatureView.h"
#import <QuartzCore/QuartzCore.h>

#define StrWidth 210
#define StrHeight 20

static CGPoint midpoint(CGPoint p0,CGPoint p1) {
    return (CGPoint) {
        (p0.x + p1.x) /2.0,
        (p0.y + p1.y) /2.0
    };
}

@interface CSXSignatureView () {
    UIBezierPath *path;
    CGPoint previousPoint;
    BOOL isHaveDraw;
    //书写范围的最小位置
    CGFloat minX;
    //书写范围的最大位置
    CGFloat maxX;
}

@end

@implementation CSXSignatureView

- (void)commonInit {
    path = [UIBezierPath bezierPath];
    [path setLineWidth:2];
    
    maxX = 0;
    minX = 0;
    // Capture touches
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    pan.maximumNumberOfTouches = 1;
    [self addGestureRecognizer:pan];
}

- (void)clearPan {
    path = [UIBezierPath bezierPath];
    [path setLineWidth:2];
    [self setNeedsDisplay];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self commonInit];
        self.currentPointArr = [NSMutableArray array];
        self.hasSignatureImg = NO;
        isHaveDraw = NO;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
         [self commonInit];
    }
    return self;
}

- (UIImage*)imageBlackToTransparent:(UIImage*)image {
    // 分配内存
    const int imageWidth = image.size.width;
    const int imageHeight = image.size.height;
    size_t bytesPerRow = imageWidth * 4;
    uint32_t *rgbImageBuf = (uint32_t *)malloc(bytesPerRow * imageHeight);
    // 创建context
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(rgbImageBuf, imageWidth, imageHeight, 8, bytesPerRow, colorSpace,
                                                 kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
    CGContextDrawImage(context, CGRectMake(0, 0, imageWidth, imageHeight), image.CGImage);
    // 遍历像素
    int pixelNum = imageWidth * imageHeight;
    uint32_t *pCurPtr = rgbImageBuf;
    for (int i = 0; i < pixelNum; i++, pCurPtr++) {
        //        if ((*pCurPtr & 0xFFFFFF00) == 0)    //将黑色变成透明
        if (*pCurPtr == 0xffffff)
        {
            uint8_t *ptr = (uint8_t *)pCurPtr;
            ptr[0] = 0;
        }
        
        //改成下面的代码，会将图片转成灰度
        /*uint8_t* ptr = (uint8_t*)pCurPtr;
         // gray = red * 0.11 + green * 0.59 + blue * 0.30
         uint8_t gray = ptr[3] * 0.11 + ptr[2] * 0.59 + ptr[1] * 0.30;
         ptr[3] = gray;
         ptr[2] = gray;
         ptr[1] = gray;*/
    }
    
    // 将内存转成image
    CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, rgbImageBuf, bytesPerRow * imageHeight,/*ProviderReleaseData**/NULL);
    CGImageRef imageRef = CGImageCreate(imageWidth, imageHeight, 8, 32, bytesPerRow, colorSpace,
                                        kCGImageAlphaLast | kCGBitmapByteOrder32Little, dataProvider,
                                        NULL, true,kCGRenderingIntentDefault);
    CGDataProviderRelease(dataProvider);
    UIImage *resultUIImage = [UIImage imageWithCGImage:imageRef];
    // 释放
    CGImageRelease(imageRef);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    return resultUIImage;
}

- (void)handelSingleTap:(UITapGestureRecognizer*)tap {
    return [self imageRepresentation];
}

- (void)imageRepresentation {
    UIGraphicsBeginImageContextWithOptions(self.bounds.size,NO, [UIScreen mainScreen].scale);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    image = [self imageBlackToTransparent:image];
    NSLog(@"width:%f,height:%f",image.size.width,image.size.height);
    UIImage *img = [self cutImage:image];
    
    self.signatureImg = [self scaleToSize:img];
    if (self.delegate && [self.delegate respondsToSelector:@selector(getSignatureImg:)]) {
        [self.delegate getSignatureImg:self.signatureImg];
    }
}

//压缩图片
- (UIImage *)scaleToSize:(UIImage *)img {
    CGRect rect = CGRectMake(0,0, img.size.width,self.frame.size.height);
    CGSize size = rect.size;
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    [img drawInRect:rect];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    //保存到本地
    //    UIImageWriteToSavedPhotosAlbum(scaledImage,nil, nil, nil);
    [self setNeedsDisplay];
    return scaledImage;
}

//只截取签名部分图片
- (UIImage *)cutImage:(UIImage *)image {
    CGRect rect ;
    //签名事件没有发生
    if(minX == 0 && maxX == 0) {
        rect = CGRectMake(0,0, 0, 0);
    } else {//签名发生
        rect = CGRectMake(minX-3, 0, maxX-minX+6, self.frame.size.height);
    }
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], rect);
    UIImage *img = [UIImage imageWithCGImage:imageRef];
    
    UIImage *lastImage = [self addText:img text:self.showMessage];
    CGImageRelease(imageRef);
    [self setNeedsDisplay];
    return lastImage;
}

//签名完成，给签名照添加新的水印
- (UIImage *)addText:(UIImage *)img text:(NSString *)mark {
    int w = img.size.width;
    int h = img.size.height;
    
    //根据截取图片大小改变文字大小
    CGFloat size = 20;
    UIFont *textFont = [UIFont systemFontOfSize:size];
    //首先根据长度来定高度，如果高度大于图片高度，那么由高度限制长度
    CGRect sizeOfTxt = [mark boundingRectWithSize:CGSizeMake(w,0) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:textFont}
                                          context: nil];
    if (sizeOfTxt.size.height>h) {
        sizeOfTxt = [mark boundingRectWithSize:CGSizeMake(0,h) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:textFont}
                                       context: nil];
    }
    
    UIGraphicsBeginImageContextWithOptions(img.size, NO, [UIScreen mainScreen].scale);
    [[UIColor redColor] set];
    [img drawInRect:CGRectMake(0,0, w, h)];
    [mark drawInRect:CGRectMake((w-sizeOfTxt.size.width)/2,(h-sizeOfTxt.size.height)/2, sizeOfTxt.size.width, sizeOfTxt.size.height) withAttributes:@{NSFontAttributeName:textFont}];
    UIImage *aimg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return aimg;
}
- (void)pan:(UIPanGestureRecognizer *)pan {
    CGPoint currentPoint = [pan locationInView:self];
    CGPoint midPoint = midpoint(previousPoint, currentPoint);
    NSLog(@"获取到的触摸点的位置为--currentPoint:%@",NSStringFromCGPoint(currentPoint));
    [self.currentPointArr addObject:[NSValue valueWithCGPoint:currentPoint]];
    self.hasSignatureImg = YES;
    CGFloat viewHeight = self.frame.size.height;
    CGFloat currentY = currentPoint.y;
    if (pan.state == UIGestureRecognizerStateBegan) {
        [path moveToPoint:currentPoint];
    } else if (pan.state == UIGestureRecognizerStateChanged) {
        [path addQuadCurveToPoint:midPoint controlPoint:previousPoint];
    }
    
    if(0 <= currentY && currentY <= viewHeight) {
        if(maxX == 0 && minX == 0) {
            maxX = currentPoint.x;
            minX = currentPoint.x;
        } else {
            if(maxX <= currentPoint.x) {
                maxX = currentPoint.x;
            }
            if(minX >= currentPoint.x) {
                minX = currentPoint.x;
            }
        }
    }
    
    previousPoint = currentPoint;
    
    [self setNeedsDisplay];
    isHaveDraw = YES;
    if (self.delegate && [self.delegate respondsToSelector:@selector(onSignatureWriteAction)]) {
        [self.delegate onSignatureWriteAction];
    }
}

- (void)drawRect:(CGRect)rect {
//    self.backgroundColor = [UIColor whiteColor];
    [[UIColor blackColor] setStroke];
    [path stroke];
    
    /*self.layer.cornerRadius =5.0;
     self.clipsToBounds =YES;
     self.layer.borderWidth =0.5;
     self.layer.borderColor = [[UIColor grayColor] CGColor];*/
    
    CGContextRef context =UIGraphicsGetCurrentContext();
    
    if(!isHaveDraw) {
        NSString *str = @"此处手写签名: 正楷, 工整书写";
        CGContextSetRGBFillColor (context, 199/255.0, 199/255.0,199/255.0, 1.0);//设置填充颜色
        CGRect rect1 = CGRectMake((rect.size.width -StrWidth)/2, (rect.size.height -StrHeight)/3-5,StrWidth, StrHeight);
        UIFont  *font = [UIFont systemFontOfSize:15];//设置字体
        [str drawInRect:rect1 withAttributes:@{NSFontAttributeName:font}];
    }
}

- (void)clear {
    if (self.currentPointArr && self.currentPointArr.count > 0) {
        [self.currentPointArr removeAllObjects];
    }
    self.hasSignatureImg = NO;
    maxX = 0;
    minX = 0;
    path = [UIBezierPath bezierPath];
    [path setLineWidth:2];
    isHaveDraw = NO;
    [self setNeedsDisplay];
}

- (void)sure {
    //没有签名发生时
    if(minX == 0 & maxX == 0) {
        minX = 0;
        maxX = 0;
    }
    [self setNeedsDisplay];
    return [self imageRepresentation];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
