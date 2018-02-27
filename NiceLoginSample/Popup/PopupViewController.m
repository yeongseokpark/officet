//
//  PopupViewController.m
//  PopupTest
//
//  Created by 박영석 on 2018. 1. 23..
//  Copyright © 2018년 myname. All rights reserved.
//

#import "PopupViewController.h"
#import "ViewController.h"
#import "ImagePickerController.h"
#import "ImagePickerGridHeaderView.h"
#import "ImagePickerGridViewCell.h"
#import "ImagePickerAlbumListViewCell.h"
#import "AppDelegate.h"
#import "WebViewController.h"
@interface PopupViewController ()

@end

@implementation PopupViewController
@synthesize bodyView,mainView,closeImage,galleryImage,cameraImage;



// 촬영 종료 시에 호출되는 메소드
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{NSLog(@"2");
    // 촬영한 이미지를 ImageView로 전달한다
    
    
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    NSLog(@"%@",[info objectForKey:UIImagePickerControllerOriginalImage]);
    
    
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    
    
                    // image to base64
                    NSString *base64Content = [UIImageJPEGRepresentation(image, IMAGEUPLOAD_JPEG_QUALITY) base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
                    NSString *imageType = @"image/jpeg";
                    //    GPAirLogD(@"image data : %d", UIImageJPEGRepresentation(image, IMAGEUPLOAD_JPEG_QUALITY).length);
                    //  GPAirLogD(@"base64Content : %d", (int)[base64Content length]);
                    //   NSLog(@"base64:%@", base64Content);
    
    
                    // send to webview
                    WebViewController* viewcontroller;
                    viewcontroller = [[WebViewController alloc]init];
                    dispatch_async(dispatch_get_main_queue(), ^ {
                        NSString *script = [NSString stringWithFormat:@"receiveImage('%@')", base64Content];
                        [viewcontroller callWebview:script];
                        //[mainWebview stringByEvaluatingJavaScriptFromString:script];
                    });
        });
            
    
    
    
    
    // 카메라를 닫는다
    [self dismissViewControllerAnimated:YES completion:nil];
}

// 촬영 취소 시에 호출되는 메소드
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
  
    
    // 촬영이 취소된 경우도 카메라를 닫는다
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)savePicture:(id)sender
{
    // 사진을 포토앨범에 저장
  //  UIImageWriteToSavedPhotosAlbum(imageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
}

// 저장 종료 시에 호출되는 메소드
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    NSLog(@"1");
    if (error) {
        // 저장 실패의 사용자 처리
        NSLog(@"%@ : %@ (%d) ", error.domain, error.localizedDescription, error.code);
    } else {
        // 저장 성공의 사용자 처리
       
    }
}



//
//// 저장 완료 시에 호출되는 메서드
//
//- (void)image:(UIImage*)image didFinishSavingWithError:(NSError*)error contextInfo:(void*)contextInfo {
//
//    NSLog(@"doneCall");
//
//    if (error) {
//
//        // 저장 실패의 사용자 처리
//
//    } else {
//
//        // 저장 성공의 사용자 처리
//
//    }
//
//
//
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
//
//        // sync
//        option.synchronous = YES;
//
//
//
//        // image resize
//        option.resizeMode = PHImageRequestOptionsResizeModeExact;
//        option.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
//
//
//        for (PHAsset *asset in self.selectedAssets) {
//
//
//            @autoreleasepool {
//                // get image
//                __block UIImage *image = nil;
//
//                [[PHImageManager defaultManager] requestImageForAsset:asset
//                                                           targetSize:IMAGEUPLOAD_MINSIZE
//                                                          contentMode:PHImageContentModeAspectFit
//                                                              options:option
//                                                        resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
//
//                                                            image = result;
//                                                        }];
//
//
//
//                // image to base64
//                NSString *base64Content = [UIImageJPEGRepresentation(image, IMAGEUPLOAD_JPEG_QUALITY) base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
//                NSString *imageType = @"image/jpeg";
//                //    GPAirLogD(@"image data : %d", UIImageJPEGRepresentation(image, IMAGEUPLOAD_JPEG_QUALITY).length);
//                //  GPAirLogD(@"base64Content : %d", (int)[base64Content length]);
//                //   NSLog(@"base64:%@", base64Content);
//
//
//                // send to webview
//                ViewController* viewcontroller;
//                viewcontroller = [[ViewController alloc]init];
//                dispatch_async(dispatch_get_main_queue(), ^ {
//                    NSString *script = [NSString stringWithFormat:@"inputAdd('%@')", base64Content];
//                    [viewcontroller callWebview:script];
//                    //[mainWebview stringByEvaluatingJavaScriptFromString:script];
//                });
//            }
//        }
//
//    });
//
//
//}

- (id)initWithCoder:(NSCoder *)aDecoder {
    NSLog(@"sssssss");
    if(self = [super initWithCoder:aDecoder]){
        [[NSBundle mainBundle]loadNibNamed:@"PopupViewController" owner:self options:nil];
        [self.mainView addSubview:self.view];
    }
    return self;
}
-(void)viewWillAppear:(BOOL)animated{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app.imgdata removeAllObjects];
}
- (void)viewDidLoad {
      NSLog(@"aaaaa");
    [super viewDidLoad];
    
    UITapGestureRecognizer *closeTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeTapDetected)];
    closeTap.numberOfTapsRequired = 1;
    [closeImage setUserInteractionEnabled:YES];
    [closeImage addGestureRecognizer:closeTap];

    UITapGestureRecognizer *cameraTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cameraTapDetected)];
    cameraTap.numberOfTapsRequired = 1;
    [cameraImage setUserInteractionEnabled:YES];
    [cameraImage addGestureRecognizer:cameraTap];

    UITapGestureRecognizer *galleryTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(galleryTapDetected)];
    galleryTap.numberOfTapsRequired = 1;
    [galleryImage setUserInteractionEnabled:YES];
    [galleryImage addGestureRecognizer:galleryTap];
    
}

-(void)closeTapDetected{
    NSLog(@"close Tap on imageview");
    [[self view]removeFromSuperview];
}

-(void)cameraTapDetected{
    NSLog(@"camera Tap on imageview");
    // 카메라를 이용할 수 있는지 확인
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        // 인스턴스 생성
        UIImagePickerController* imagePickerController = [[UIImagePickerController alloc] init];
        
        // 카메라에서의 취득을 지정
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        // 촬영 후의 편집 불가
        imagePickerController.allowsEditing = NO;
        
        // 델리게이트를 이 클래스에 지정
        imagePickerController.delegate = self;
        
        // 실행
        [self presentViewController:imagePickerController animated:YES completion:nil];
    }

    [[self view]removeFromSuperview];
}

-(void)galleryTapDetected{
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    
        UIViewController *view = [storyboard instantiateViewControllerWithIdentifier:@"ImageVC"];
    
        [self presentViewController:view animated:TRUE completion:nil];
    
    NSLog(@"gallery Tap on imageview");
    [[self view]removeFromSuperview];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)ClosePopupView:(UIImageView*)sender{
    [[self view]removeFromSuperview];
    
}


@end
