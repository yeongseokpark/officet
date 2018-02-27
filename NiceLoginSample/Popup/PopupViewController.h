//
//  PopupViewController.h
//  PopupTest
//
//  Created by 박영석 on 2018. 1. 23..
//  Copyright © 2018년 myname. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PopupViewController : UIViewController  <UINavigationControllerDelegate, UIImagePickerControllerDelegate>


@property (weak,nonatomic) IBOutlet UIView *mainView;
@property (weak,nonatomic) IBOutlet UIView *bodyView;
@property (weak, nonatomic) IBOutlet UIImageView *closeImage;
@property (weak, nonatomic) IBOutlet UIImageView *cameraImage;
@property (weak, nonatomic) IBOutlet UIImageView *galleryImage;
- (IBAction)ClosePopupView:(UIImageView*)sender;
@end
