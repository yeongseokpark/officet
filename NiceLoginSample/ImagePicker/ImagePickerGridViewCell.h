

@import UIKit;
@import Photos;
#import <M13ProgressSuite/M13ProgressViewPie.h>

@interface ImagePickerGridViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet M13ProgressViewPie *progressView;
@property (nonatomic, strong) UIImage *thumbnailImage;
@property (nonatomic, assign) NSInteger selectionIndex;

@property (nonatomic, copy) NSString *representedAssetIdentifier;
@property (nonatomic, assign) PHImageRequestID imageRequestID;

@end

