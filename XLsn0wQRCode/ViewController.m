#import <ImageIO/ImageIO.h>
#import "ViewController.h"
#import "ScanCodeManager.h"
#import <AVFoundation/AVFoundation.h>

#import "ReplicatorAnimation.h"

#define SCREEN_WIDTH  [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface ViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate, AVCaptureVideoDataOutputSampleBufferDelegate>


@property (nonatomic, strong) AVCaptureSession *session;


@property (nonatomic, strong) UIImageView *rectImageView;

@property (nonatomic, strong) UIButton *torchBtn; // 闪光灯按钮
@property (nonatomic, strong) UIButton *photoBtn; // 相册按钮

@property (nonatomic, assign) BOOL isOpen; // 相册按钮

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isOpen = false;
    //self.title = @"逆变器2222222222222222";
    //    NSDictionary *titleAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:10],
    //                                 NSForegroundColorAttributeName:[UIColor redColor]};
    //    [self.navigationController.navigationBar setTitleTextAttributes:titleAttributes];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
    titleLabel.backgroundColor = [UIColor grayColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:20];
    titleLabel.textColor = [UIColor greenColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = @"逆变器2222222222222222";
    self.navigationItem.titleView = titleLabel;

    
    [self.view.layer addSublayer:[ReplicatorAnimation replicatorLayerWithType:(YUReplicatorLayerWave)]];
    
    
    [self initContent];
    [self startScanCode];
//    [self lightSensitive];
}

- (void)initContent {

    [self.view addSubview:self.rectImageView];
    [self.view addSubview:self.photoBtn];
    [self.view addSubview:self.torchBtn];
}

- (void)startScanCode {
    

}

#pragma mark - button action

- (void)torchBtnAction:(UIButton *)btn {
    
    if ([[ScanCodeManager manager] torchIsOn]) {
        
        [[ScanCodeManager manager] offTorch];
    } else {
        [[ScanCodeManager manager] onTorch];
    }
}

- (void)photoBtnAction:(UIButton *)btn {
    
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    imagePickerController.allowsEditing = YES;
    
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    __weak typeof(self) weakSelf = self;
    UIImage *pickImage =  [info objectForKey:UIImagePickerControllerEditedImage];
    if (!pickImage){
        pickImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    [[ScanCodeManager manager] scanQRCodeFormImage:pickImage completeHandler:^(NSString *code) {
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf scanCodeSuccessWith:code];
    }];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)scanCodeSuccessWith:(NSString *)code {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"扫描结果" message:code preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // 重置扫码状态
        [[ScanCodeManager manager] resetScanState];
    }];
    [alertController addAction:action1];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (BOOL)canOpenCamera{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusRestricted || authStatus ==AVAuthorizationStatusDenied)
    {
        NSString *tips = [NSString stringWithFormat:@"请在iPhone的”设置-隐私-照片“选项中，允许%@访问你的相机",NSLocalizedString(@"AppName",@"EnnNew")];
        //无权限 做一个友好的提示
        UIAlertView * alart = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:tips delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alart show];
        return NO;
    }
    return YES;

}

- (UIButton *)torchBtn {
    if (!_torchBtn) {
        _torchBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-36.f-20.f, 40.f, 36.f, 36.f)];
        [_torchBtn setImage:[UIImage imageNamed:@"scan_light"] forState:UIControlStateNormal];
        [_torchBtn addTarget:self action:@selector(torchBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _torchBtn;
}

- (UIButton *)photoBtn {
    if (!_photoBtn) {
        _photoBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-(36.f+20.f)*2, 40.f, 36.f, 36.f)];
        [_photoBtn setImage:[UIImage imageNamed:@"scan_photo_album"] forState:UIControlStateNormal];
        [_photoBtn addTarget:self action:@selector(photoBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _photoBtn;
}


- (void)dealloc {
    
    [[ScanCodeManager manager] stopScan];
}





@end
