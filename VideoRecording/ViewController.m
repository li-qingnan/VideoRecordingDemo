//
//  ViewController.m
//  VideoRecording
//
//  Created by Yinan on 16/3/14.
//  Copyright © 2016年 Yinan. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "PlayViewController.h"

@interface ViewController ()<AVCaptureFileOutputRecordingDelegate>

@property (nonatomic ,strong) AVCaptureMovieFileOutput *output;
@property (weak, nonatomic) IBOutlet UIView *bgView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self baseInitial];
    self.navigationItem.title = @"视频录制";
}

- (void)baseInitial
{
    //    一，初始化输入设备，这里涉及到前，后摄像头；麦克风（导入AVFoundation）
    //1.创建视频设备(摄像头前，后)
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    
    //2.初始化一个摄像头输入设备(first是后置摄像头，last是前置摄像头)
    AVCaptureDeviceInput *inputVideo = [AVCaptureDeviceInput deviceInputWithDevice:[devices firstObject] error:NULL];
    //3.创建麦克风设备
    AVCaptureDevice *deviceAudio = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    //4.初始化麦克风输入设备
    AVCaptureDeviceInput *inputAudio = [AVCaptureDeviceInput deviceInputWithDevice:deviceAudio error:NULL];
    
    //    二，初始化视频文件输出
    //5.初始化一个movie的文件输出
    AVCaptureMovieFileOutput *output = [[AVCaptureMovieFileOutput alloc] init];
    self.output = output; //保存output，方便下面操作
    
    //    三,初始化会话，并将输入输出设备添加到会话中
    //6.初始化一个会话
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    
    //7.将输入输出设备添加到会话中
    if ([session canAddInput:inputVideo]) {
        [session addInput:inputVideo];
    }
    if ([session canAddInput:inputAudio]) {
        [session addInput:inputAudio];
    }
    if ([session canAddOutput:output]) {
        [session addOutput:output];
    }
    
    //   四，添加一个视频预览图层，设置大小，添加到控制器view的图层上
    //8.创建一个预览涂层
    AVCaptureVideoPreviewLayer *preLayer = [AVCaptureVideoPreviewLayer layerWithSession:session];
    //设置图层的大小
    preLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    preLayer.bounds = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 300);
    preLayer.position = CGPointMake([UIScreen mainScreen].bounds.size.width/2, 300/2);
    //添加到view上
    [self.bgView.layer addSublayer:preLayer];
    
    //    五，开始会话
    //9.开始会话
    [session startRunning];
}


- (IBAction)playOrPause:(id)sender {
    //判断是否在录制,如果在录制，就停止，并设置按钮title
    if ([self.output isRecording]) {
        [self.output stopRecording];
        [sender setTitle:@"开始录制" forState:UIControlStateNormal];
        return;
    }
    
    //设置按钮的title
    [sender setTitle:@"停止" forState:UIControlStateNormal];
    
    //10.开始录制视频
    //设置录制视频保存的路径
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:@"myVidio.mov"];
    
    //转为视频保存的url
    NSURL *url = [NSURL fileURLWithPath:path];
    
    //开始录制,并设置控制器为录制的代理
    [self.output startRecordingToOutputFileURL:url recordingDelegate:self];
}


//七，实现代理方法（这里只实现一个完成代理方法吧，其他根据自己的需求再设置）
#pragma  mark - AVCaptureFileOutputRecordingDelegate
//录制完成代理
- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error
{
    NSLog(@"完成录制,可以自己做进一步的处理");
    
    PlayViewController *playVC = [[PlayViewController alloc] initWithNibName:@"PlayViewController" bundle:nil];
    playVC.playUrl = outputFileURL;
    [self.navigationController pushViewController:playVC animated:YES];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
