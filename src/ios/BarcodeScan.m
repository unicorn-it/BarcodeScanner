//
//  BarcodeScan.m
//
//  Created by Adowya on 14-09-20.
//
//

#import "BarcodeScan.h"

@implementation BarcodeScan

//--------------------------------------------------------------------------
- (NSString*)isScanNotPossible {
    NSString* result = nil;
    
    Class aClass = NSClassFromString(@"AVCaptureSession");
    if (aClass == nil) {
        return @"AVFoundation Framework not available";
    }
    
    return result;
}

//--------------------------------------------------------------------------
- (void)scan:(CDVInvokedUrlCommand*)command {
    
    NSString*       callback;
    NSString*       capabilityError;
    NSString* myarg = [command.arguments objectAtIndex:0];
    NSString* myarg2 = [command.arguments objectAtIndex:1];
    BOOL myarg3 = [[command.arguments objectAtIndex:2] boolValue];
    NSLog(@"%@", myarg);
    
    if (myarg != nil) {
    } else {
        [self returnError:@"Arg was null" callback:callback];
        return;
    }
    
    if (myarg2 != nil) {
    } else {
        [self returnError:@"Arg was null" callback:callback];
        return;
    }
    
    callback = command.callbackId;
    
    capabilityError = [self isScanNotPossible];
    if (capabilityError) {
        [self returnError:capabilityError callback:callback];
        return;
    }
    
    RootViewController * rt = [[RootViewController alloc]initWithPlugin:self msg:myarg buttonText:myarg2 scanner:&myarg3 callback:callback];
    [self.viewController presentViewController:rt animated:YES completion:^{
        
    }];
    
}

//--------------------------------------------------------------------------
- (void)encode:(CDVInvokedUrlCommand*)command {
    [self returnError:@"encode function not supported" callback:command.callbackId];
}

//--------------------------------------------------------------------------
- (void)returnSuccess:(NSString*)scannedText format:(NSString*)format cancelled:(BOOL)cancelled callback:(NSString*)callback {
    NSNumber* cancelledNumber = [NSNumber numberWithInt:(cancelled?1:0)];
    
    NSMutableDictionary* resultDict = [[NSMutableDictionary alloc] init];
    [resultDict setObject:scannedText     forKey:@"text"];
    [resultDict setObject:format          forKey:@"format"];
    [resultDict setObject:cancelledNumber forKey:@"cancelled"];
    
    CDVPluginResult* result = [CDVPluginResult
                               resultWithStatus: CDVCommandStatus_OK
                               messageAsDictionary: resultDict
                               ];
    
    NSString* js = [result toSuccessCallbackString:callback];
    
    [self writeJavascript:js];
}

//--------------------------------------------------------------------------
- (void)returnError:(NSString*)message callback:(NSString*)callback {
    CDVPluginResult* result = [CDVPluginResult
                               resultWithStatus: CDVCommandStatus_OK
                               messageAsString: message
                               ];
    
    NSString* js = [result toErrorCallbackString:callback];
    
    [self writeJavascript:js];
}

@end








@implementation RootViewController

@synthesize plugin               = _plugin;
@synthesize msg                  = _msg;
@synthesize scanner                  = _scanner;
@synthesize callback             = _callback;


- (id)initWithPlugin:(BarcodeScan *)plugin msg:(NSString*)msg buttonText:(NSString*)buttonText scanner:(BOOL*)scanner callback:(NSString*)callback
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        // Custom initialization
        self.plugin = plugin;
        self.msg = msg;
        self.buttonText = buttonText;
        self.scanner = *(scanner);
        self.callback = callback;
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton * scanButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [scanButton setTitle:self.buttonText forState:UIControlStateNormal];
    scanButton.frame = CGRectMake(0, self.view.bounds.size.height - 40, self.view.bounds.size.width, 40);
    scanButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    scanButton.backgroundColor = [UIColor colorWithWhite:0.95 alpha:0.65];
    [scanButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:scanButton];
    
    if(self.scanner){
        
        UINavigationBar *_navcon =[[UINavigationBar alloc] init];
        [_navcon setFrame:CGRectMake(0,0, self.view.bounds.size.width,64)];
        UINavigationItem *navItem = [[UINavigationItem alloc] init];
        UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Manuel" style:UIBarButtonItemStyleDone target:self action:@selector(SwitchAction)];
        navItem.rightBarButtonItem = rightButton;
        _navcon.items = @[ navItem ];
        [self.view addSubview:_navcon];
        
    }
    
    UILabel * labIntroudction= [[UILabel alloc] initWithFrame:CGRectMake(50, self.view.bounds.size.height - 150, self.view.bounds.size.width, 50)];
    labIntroudction.backgroundColor = [UIColor clearColor];
    labIntroudction.numberOfLines=2;
    labIntroudction.textColor=[UIColor blackColor];
    labIntroudction.text=self.msg;
    [self.view addSubview:labIntroudction];
    
    
    UIImageView * imageView = [[UIImageView alloc]initWithFrame:CGRectMake(30, 100, 260, 260)];
    imageView.image = [UIImage imageNamed:@"pick_bg"];
    [self.view addSubview:imageView];
    
    upOrdown = NO;
    num =0;
    _line = [[UIImageView alloc] initWithFrame:CGRectMake(50, 110, 220, 2)];
    _line.image = [UIImage imageNamed:@"line.png"];
    [self.view addSubview:_line];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:.008 target:self selector:@selector(animation1) userInfo:nil repeats:YES];
}

-(void)animation1
{
    if (upOrdown == NO) {
        num ++;
        _line.frame = CGRectMake(50, 130+2*num, 220, 2);
        if (2*num == 200) {
            upOrdown = YES;
        }
    }
    else {
        num --;
        _line.frame = CGRectMake(50, 130+2*num, 220, 2);
        if (num == 0) {
            upOrdown = NO;
        }
    }
    
}

-(void)backAction
{
    
    [self dismissViewControllerAnimated:YES completion:^{
        [timer invalidate];
        [self.plugin returnSuccess:@"" format:@"" cancelled:TRUE callback:self.callback];
    }];
}

-(void)SwitchAction
{
    [self dismissViewControllerAnimated:YES completion:^{
        [timer invalidate];
        [self.plugin returnSuccess:@"SwitchScan" format:@"SwitchScan" cancelled:TRUE callback:self.callback];
    }];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self setupCamera];
}

- (void)setupCamera
{
    NSError *error = nil;
    // Device
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (_device.isAutoFocusRangeRestrictionSupported) {
        if ([_device lockForConfiguration:&error]) {
            [_device setAutoFocusRangeRestriction:AVCaptureAutoFocusRangeRestrictionNear];
            [_device unlockForConfiguration];
        }
    }
    
    // Input
    _input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    
    // Output
    _output = [[AVCaptureMetadataOutput alloc]init];
    [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    
    
    // Session
    _session = [[AVCaptureSession alloc]init];
    [_session setSessionPreset:AVCaptureSessionPresetHigh];
    if ([_session canAddInput:self.input])
    {
        [_session addInput:self.input];
    }
    
    if ([_session canAddOutput:self.output])
    {
        [_session addOutput:self.output];
    }
    
    _output.metadataObjectTypes =@[AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeCode39Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeQRCode];
    
    
    CGRect bounds = self.view.bounds;
    bounds = CGRectMake(0, 0, bounds.size.width, bounds.size.height);
    
    UIView* overlayView = [[UIView alloc] initWithFrame:bounds];
    overlayView.autoresizesSubviews = YES;
    overlayView.autoresizingMask    = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    overlayView.opaque              = NO;
    
    bounds = overlayView.bounds;
    CGFloat rootViewHeight = CGRectGetHeight(bounds);
    CGFloat rootViewWidth  = CGRectGetWidth(bounds);
    CGFloat minAxis = MIN(rootViewHeight, rootViewWidth);
    
    if ([_preview isOrientationSupported]) {
        [_preview setOrientation:AVCaptureVideoOrientationPortrait];
    }
    
    // Preview
    _preview =[AVCaptureVideoPreviewLayer layerWithSession:self.session];
    _preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _preview.frame = self.view.bounds;
    [self.view.layer insertSublayer:self.preview atIndex:0];
    
    
    
    // Start
    [_session startRunning];
}
#pragma mark AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    
    NSString *stringValue;
    NSString *format = nil;
    
    
    if ([metadataObjects count] >0)
    {
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex:0];
        
        if ([[metadataObject type] isEqualToString:AVMetadataObjectTypeEAN13Code]) {
            format =[NSString stringWithFormat:@"EAN_13"];
        }
        else if ([[metadataObject type] isEqualToString:AVMetadataObjectTypeEAN8Code]) {
            format = [NSString stringWithFormat:@"EAN_8"];
        }
        else if ([[metadataObject type] isEqualToString:AVMetadataObjectTypeCode39Code]) {
            format = [NSString stringWithFormat:@"CODE_39"];
        }
        else if ([[metadataObject type] isEqualToString:AVMetadataObjectTypeQRCode]) {
            format = [NSString stringWithFormat:@"QR_CODE"];
        }
        
        stringValue = metadataObject.stringValue;
        
    }
    
    [_session stopRunning];
    [self dismissViewControllerAnimated:YES completion:^
     {
         [timer invalidate];
         NSLog(@"%@",stringValue);
         NSLog(@"%@",format);
         [self.plugin returnSuccess:stringValue format:format cancelled:FALSE callback:self.callback];
     }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    self.plugin = nil;
    self.msg = nil;
    self.scanner = nil;
    self.callback = nil;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

@end

