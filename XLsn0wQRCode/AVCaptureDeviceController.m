
//
#import <ImageIO/ImageIO.h>
#import <AVFoundation/AVFoundation.h>
#import "AVCaptureDeviceController.h"

@interface AVCaptureDeviceController () <AVCaptureVideoDataOutputSampleBufferDelegate>

@property (nonatomic, strong) AVCaptureSession *session;///
@property (nonatomic, strong) AVCaptureDevice *device;///

@end

@implementation AVCaptureDeviceController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationItem.title = @"光感";
    [self lightSensitive];
}

#pragma mark- 光感
- (void)lightSensitive {
    
    // 1.获取硬件设备
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // 2.创建输入流
    AVCaptureDeviceInput *input = [[AVCaptureDeviceInput alloc] initWithDevice:self.device error:nil];
    
    // 3.创建设备输出流
    AVCaptureVideoDataOutput *output = [[AVCaptureVideoDataOutput alloc] init];
    [output setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
    
    
    // AVCaptureSession属性
    self.session = [[AVCaptureSession alloc]init];
    // 设置为高质量采集率
    [self.session setSessionPreset:AVCaptureSessionPresetHigh];
    // 添加会话输入和输出
    if ([self.session canAddInput:input]) {
        [self.session addInput:input];
    }
    if ([self.session canAddOutput:output]) {
        [self.session addOutput:output];
    }
    
    // 9.启动会话
    [self.session startRunning];
    
}

#pragma mark- AVCaptureVideoDataOutputSampleBufferDelegate的方法
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    
    CFDictionaryRef metadataDict = CMCopyDictionaryOfAttachments(NULL,sampleBuffer, kCMAttachmentMode_ShouldPropagate);
    NSDictionary *metadata = [[NSMutableDictionary alloc] initWithDictionary:(__bridge NSDictionary*)metadataDict];
    CFRelease(metadataDict);
    NSDictionary *exifMetadata = [[metadata objectForKey:(NSString *)kCGImagePropertyExifDictionary] mutableCopy];
    float brightnessValue = [[exifMetadata objectForKey:(NSString *)kCGImagePropertyExifBrightnessValue] floatValue];
    
    NSLog(@"brightnessValue= %f",brightnessValue);
    
    
    /// 根据brightnessValue的值来打开和关闭闪光灯
    BOOL result = [self.device hasTorch];// 判断设备是否有闪光灯
    if ((brightnessValue < 0) && result) {// 打开闪光灯
        [self.device lockForConfiguration:nil];
        [self.device setTorchMode: AVCaptureTorchModeOn];//开
        [self.device unlockForConfiguration];
    } else if((brightnessValue > 0) && result && (self.device.torchMode == AVCaptureTorchModeOn)) {// 关闭闪光灯
        [self.device lockForConfiguration:nil];
        [self.device setTorchMode: AVCaptureTorchModeOff];//关
        [self.device unlockForConfiguration];
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
