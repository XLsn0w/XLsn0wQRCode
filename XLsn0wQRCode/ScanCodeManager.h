
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, ScanType) {
    ScanTypeQRCode =  1 << 0,
    ScanTypeBarCode = 1 << 1,
};

@interface ScanCodeManager : NSObject

+ (instancetype)manager;

/**
 二维码扫描
 
 @param type     扫码的类型 (二维码、条形码  兼容：ScanTypeQRCode|ScanTypeBarCode)
 @param scanView 扫码的view 扫描区域为整个view
 @param completeHandler 扫码完成回调
 */
- (void)scanCodeWithType:(ScanType)type
                scanView:(UIView *)scanView
         completeHandler:(void(^)(NSString *code))completeHandler;
/**
 二维码扫描

 @param type     扫码的类型 (二维码、条形码  兼容：ScanTypeQRCode|ScanTypeBarCode)
 @param scanView 扫码的view
 @param scanRect 扫码的区域
 @param completeHandler 扫码完成回调
 */
- (void)scanCodeWithType:(ScanType)type
                scanView:(UIView *)scanView
                scanRect:(CGRect)scanRect
         completeHandler:(void(^)(NSString *code))completeHandler;

/**
 识别图片中的二维码

 @param scanImage 扫码的图片
 @param completeHandler 扫码完成回调
 */
- (void)scanQRCodeFormImage:(UIImage *)scanImage
            completeHandler:(void(^)(NSString *code))completeHandler;

/**
 重置扫描状态 默认扫描成功之后就停止扫描
 */
- (void)resetScanState;

/**
 停止扫描
 */
- (void)stopScan;

/**
 打开闪光灯
 */
- (void)onTorch;

/**
 关闭闪光灯
 */
- (void)offTorch;

/**
 当前闪关灯的状态
 
 @return YES 打开状态  NO 关闭状态
 */
- (BOOL)torchIsOn;

@end
