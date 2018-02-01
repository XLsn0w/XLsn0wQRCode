
#import "ScanCodeManager.h"
#import <AVFoundation/AVFoundation.h>

#define HY_SCREEN_WIDTH  [UIScreen mainScreen].bounds.size.width
#define HY_SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface ScanCodeManager ()<AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;

@property (nonatomic, copy) void (^completeHandler)(NSString *code);

@end

@implementation ScanCodeManager
{
    BOOL _isScanComplete;
    BOOL _torchIsOn;
}

+ (instancetype)manager {
    
    static id _instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

#pragma mark - 二维码扫描

- (void)scanCodeWithType:(ScanType)type scanView:(UIView *)scanView completeHandler:(void(^)(NSString *code))completeHandler {
    
    [self scanCodeWithType:type scanView:scanView scanRect:scanView.frame completeHandler:completeHandler];
}

- (void)scanCodeWithType:(ScanType)type scanView:(UIView *)scanView scanRect:(CGRect)scanRect completeHandler:(void(^)(NSString *code))completeHandler {
    self.completeHandler = completeHandler;
    _isScanComplete = NO;

    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    
    if (input == nil) {
        return;
    }
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    self.session = [[AVCaptureSession alloc] init];
    if ([self.session canAddInput:input]) {
        [self.session addInput:input];
    }
    if ([self.session canAddOutput:output]) {
        [self.session addOutput:output];
    }
    
    NSMutableArray *metadataObjectTypes = [NSMutableArray array];
    if ((type & ScanTypeQRCode) == ScanTypeQRCode) { // 二维码扫描
        [metadataObjectTypes addObjectsFromArray:@[AVMetadataObjectTypeQRCode]];
    }
    if ((type & ScanTypeBarCode) == ScanTypeBarCode) { // 条形码扫描
        [metadataObjectTypes addObjectsFromArray:@[AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code]];
    }
    [output setMetadataObjectTypes:metadataObjectTypes];
    self.previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    self.previewLayer.frame = scanView.bounds;
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [scanView.layer insertSublayer:self.previewLayer atIndex:0];
    
    // 设置扫描区域
    UIViewController *vc = [self getCurrentViewController:scanView];
    CGRect convertRect = [scanView convertRect:scanRect toView:vc.view];
    CGFloat w = convertRect.size.width;
    CGFloat h = convertRect.size.height;
    CGFloat x = HY_SCREEN_WIDTH - convertRect.origin.x - w;
    CGFloat y = convertRect.origin.y;
    output.rectOfInterest = CGRectMake(y / HY_SCREEN_HEIGHT, x / HY_SCREEN_WIDTH, h / HY_SCREEN_HEIGHT, w / HY_SCREEN_WIDTH);
    
    [self.session startRunning];
}

- (void)scanQRCodeFormImage:(UIImage *)scanImage completeHandler:(void(^)(NSString *code))completeHandler {
    if (scanImage == nil) {
        return;
    }
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy: CIDetectorAccuracyHigh}];
        CIImage *image = [[CIImage alloc] initWithImage:scanImage];
        NSArray *features = [detector featuresInImage:image];
        
        CIQRCodeFeature *feature = features.firstObject;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completeHandler) {
                completeHandler(feature.messageString);
            }
        });
    });
}

- (void)resetScanState {
    
    _isScanComplete = NO;
}

- (void)stopScan {
    [self.previewLayer removeFromSuperlayer];
    [self.session stopRunning];
    self.session = nil;
}

#pragma mark - 开关闪光灯

- (void)onTorch {
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    if ([device hasTorch] || device.torchMode != AVCaptureTorchModeOn) {
        [device lockForConfiguration:nil];
        [device setTorchMode:AVCaptureTorchModeOn];
        [device unlockForConfiguration];
        
        _torchIsOn = YES;
    }
}

- (void)offTorch {
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    if ([device hasTorch] || device.torchMode != AVCaptureTorchModeOff) {
        [device lockForConfiguration:nil];
        [device setTorchMode:AVCaptureTorchModeOff];
        [device unlockForConfiguration];
        
        _torchIsOn = NO;
    }
}

- (BOOL)torchIsOn {
    
    return _torchIsOn;
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    
    AVMetadataMachineReadableCodeObject *metadata = metadataObjects.firstObject;
    if (_isScanComplete == NO) {
        _isScanComplete = YES;
        if (self.completeHandler) {
            self.completeHandler(metadata.stringValue);
        }
    }
}

#pragma mark - 获取view所在的控制器

- (UIViewController *)getCurrentViewController:(UIView *)view {
    for (UIView* next = [view superview]; next; next = next.superview) {
        UIResponder *nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }
    }
    return nil;
}

@end








