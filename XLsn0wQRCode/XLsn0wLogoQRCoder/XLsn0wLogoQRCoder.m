/***********************************************************************************************
 *     __      __   _         _________     _ _     _    _________   __         _         __   *
 *     \ \    / /  | |        | _______|   | | \   | |  |  ______ |  \ \       / \       / /   *
 *      \ \  / /   | |        | |          | |\ \  | |  | |     | |   \ \     / \ \     / /    *
 *       \ \/ /    | |        | |______    | | \ \ | |  | |     | |    \ \   / / \ \   / /     *
 *       /\/\/\    | |        |_______ |   | |  \ \| |  | |     | |     \ \ / /   \ \ / /      *
 *      / /  \ \   | |______   ______| |   | |   \ \ |  | |_____| |      \ \ /     \ \ /       *
 *     /_/    \_\  |________| |________|   |_|    \__|  |_________|       \_/       \_/        *
 *                                                                                             *
 ***********************************************************************************************/

#import "XLsn0wLogoQRCoder.h"

@implementation XLsn0wLogoQRCoder

+ (UIImage *)imageWithQRMessage:(NSString *)message
                      headImage:(UIImage *)headImage
           inputCorrectionLevel:(QRCodeImagerInputCorrectionLevel)correctionLevel
                     sideLength:(CGFloat)sideLength {
    
    // 准备滤镜
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    
    //  设置默认值
    [filter setDefaults];
    
    //  生成要显示的字符串数据
    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
    
    [filter setValue:data forKeyPath:@"inputMessage"];
    
    switch (correctionLevel) {
        case High:
            [filter setValue:@"H" forKeyPath:@"inputCorrectionLevel"];
            break;
        case Low:
            [filter setValue:@"L" forKeyPath:@"inputCorrectionLevel"];
            break;
            
        default:
            break;
    }
    
    // 输出
    CIImage *coreImage = [filter outputImage];
    
    //  1. 要把图像无损放大
    UIImage *QRImage = [self imageWithCIImage:coreImage andSize:CGSizeMake(sideLength, sideLength)];
    
    //  2. 要合成头像
    CGSize headSize = CGSizeMake(sideLength * 0.30, sideLength * 0.30);
    
    UIImage *QRCardImage = [self imageWithBackgroundImage:QRImage centerImage:headImage centerImageSize:headSize];
    
    return QRCardImage;
    
}

//  将CIImage转换成指定大小的UIImage
+ (UIImage *)imageWithCIImage:(CIImage *)coreImage andSize:(CGSize)size {
    
    //1. CIImage 转换成 CGImage(CGImageRef)
    CIContext *context = [CIContext contextWithOptions:nil];
    
    CGImageRef originCGImage = [context createCGImage:coreImage fromRect:coreImage.extent];
    
    //2. 创建一个图形上下文 Bitmap
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    
    CGContextRef bitmapCtx = CGBitmapContextCreate(NULL, size.width, size.height, 8, 0, cs, kCGImageAlphaNone);
    
    //3. 将CGImage图片渲染到新的图形上下文中
    CGContextSetInterpolationQuality(bitmapCtx, kCGInterpolationNone);
    
    // 在图形上下文中把图片画出来
    CGRect newRect = CGRectMake(0, 0, size.width, size.height);
    
    CGContextDrawImage(bitmapCtx, newRect, originCGImage);
    
    //4. 取图像
    CGImageRef QRImage = CGBitmapContextCreateImage(bitmapCtx);
    
    // 释放
    CGColorSpaceRelease(cs);
    
    CGImageRelease(originCGImage);
    
    CGContextRelease(bitmapCtx);
    
    
    return [UIImage imageWithCGImage:QRImage];
    
}

+ (UIImage *)imageWithBackgroundImage:(UIImage *)backgroundImage centerImage:(UIImage *)centerImage centerImageSize:(CGSize)centerSize{
    
    // 开始图形上下文
    UIGraphicsBeginImageContext(backgroundImage.size);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextSetInterpolationQuality(ctx, kCGInterpolationNone);
    
    // 先画背景
    [backgroundImage drawAtPoint:CGPointZero];
    
    // 再画头像
    CGFloat headW = centerSize.width;
    CGFloat headH = centerSize.height;
    CGFloat headX = (backgroundImage.size.width - headW) * 0.5;
    CGFloat headY = (backgroundImage.size.height - headH) * 0.5;
    
    [centerImage drawInRect:CGRectMake(headX, headY, headW, headH)];
    
    // 取图像
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
    
}


+ (XLsn0wLogoQRCoder *)codeImageWithString:(NSString *)string
                                size:(CGFloat)width
{
    CIImage *ciImage = [XLsn0wLogoQRCoder xlsn0wpay_createQRForString:string];
    if (ciImage) {
        return [XLsn0wLogoQRCoder createNonInterpolatedUIImageFormCIImage:ciImage
                                                               size:width];
    } else {
        return nil;
    }
}

+ (XLsn0wLogoQRCoder *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image
                                                    size:(CGFloat)size {
    
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent),
                        size/CGRectGetHeight(extent));
    // 1.创建一个位图图像，绘制到其大小的位图上下文
    size_t width        = CGRectGetWidth(extent) * scale;
    size_t height       = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs  = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil,
                                                   width,
                                                   height,
                                                   8,
                                                   0,
                                                   cs,
                                                   (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context     = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    // 2.创建具有内容的位图图像
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    // 3.清理
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    return (XLsn0wLogoQRCoder *)[UIImage imageWithCGImage:scaledImage];
}

+ (CIImage *)xlsn0wpay_createQRForString:(NSString *)qrString {
    // 1.将字符串转换为UTF8编码的NSData对象
    NSData *stringData = [qrString dataUsingEncoding:NSUTF8StringEncoding];
    // 2.创建filter
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    // 3.设置内容和纠错级别
    [qrFilter setValue:stringData forKey:@"inputMessage"];
    [qrFilter setValue:@"M" forKey:@"inputCorrectionLevel"];
    // 4.返回CIImage
    return qrFilter.outputImage;
}


void xlsn0wpay_ProviderReleaseData (void *info, const void *data, size_t size) {
    free((void*)data);
}

+ (XLsn0wLogoQRCoder *_Nonnull)codeImageWithString:(NSString *_Nullable)string
                                        size:(CGFloat)width
                                       color:(UIColor *_Nullable)color;
{
    
    
    XLsn0wLogoQRCoder *image = [XLsn0wLogoQRCoder codeImageWithString:string size:width];
    
    const CGFloat *components = CGColorGetComponents(color.CGColor);
    CGFloat red     = components[0]*255;
    CGFloat green   = components[1]*255;
    CGFloat blue    = components[2]*255;
    
    const int imageWidth    = image.size.width;
    const int imageHeight   = image.size.height;
    size_t      bytesPerRow = imageWidth * 4;
    uint32_t* rgbImageBuf   = (uint32_t*)malloc(bytesPerRow * imageHeight);
    
    // 1.创建上下文
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(rgbImageBuf,
                                                 imageWidth,
                                                 imageHeight,
                                                 8,
                                                 bytesPerRow,
                                                 colorSpace,
                                                 kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
    CGContextDrawImage(context, CGRectMake(0, 0, imageWidth, imageHeight), image.CGImage);
    
    // 2.像素转换
    int pixelNum = imageWidth * imageHeight;
    uint32_t* pCurPtr = rgbImageBuf;
    for (int i = 0; i < pixelNum; i++, pCurPtr++){
        if ((*pCurPtr & 0xFFFFFF00) < 0x99999900){
            uint8_t* ptr = (uint8_t*)pCurPtr;
            ptr[3] = red; //0~255
            ptr[2] = green;
            ptr[1] = blue;
        }else{
            uint8_t* ptr = (uint8_t*)pCurPtr;
            ptr[0] = 0;
        }
    }
    
    // 3.生成UIImage
    CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL,
                                                                  rgbImageBuf,
                                                                  bytesPerRow * imageHeight,
                                                                  xlsn0wpay_ProviderReleaseData);
    CGImageRef imageRef = CGImageCreate(imageWidth,
                                        imageHeight,
                                        8,
                                        32,
                                        bytesPerRow,
                                        colorSpace,
                                        kCGImageAlphaLast | kCGBitmapByteOrder32Little,
                                        dataProvider,
                                        NULL,
                                        true,
                                        kCGRenderingIntentDefault);
    CGDataProviderRelease(dataProvider);
    XLsn0wLogoQRCoder *resultUIImage = (XLsn0wLogoQRCoder *)[UIImage imageWithCGImage:imageRef];
    
    // 4.释放
    CGImageRelease(imageRef);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    return resultUIImage;
}

+ (XLsn0wLogoQRCoder *_Nonnull)codeImageWithString:(NSString *_Nullable)string
                                        size:(CGFloat)width
                                       color:(UIColor *_Nullable)color
                                        icon:(UIImage *_Nullable)icon
                                    iconWidth:(CGFloat)iconWidth {
    XLsn0wLogoQRCoder *bgImage = [XLsn0wLogoQRCoder codeImageWithString:string
                                                       size:width
                                                      color:color];
    UIGraphicsBeginImageContext(bgImage.size);
    [bgImage drawInRect:CGRectMake(0, 0, bgImage.size.width, bgImage.size.height)];
    
    CGFloat x = (bgImage.size.width - iconWidth) * 0.5;
    CGFloat y = (bgImage.size.height - iconWidth) * 0.5;
    [icon drawInRect:CGRectMake( x,  y, iconWidth,  iconWidth)];
    
    UIImage *newImage =  UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return (XLsn0wLogoQRCoder *)newImage;
}


@end
