
@import UIKit;
@import Photos;



@protocol ImagePickerControllerDelegate;

/**
 이미지픽커 뷰컨트롤러
 */
@interface ImagePickerController : UIViewController

/** 델리게이트 */
@property (nonatomic, weak) id<ImagePickerControllerDelegate> delegate;

/** 사진선택 최대개수 */
@property (nonatomic) NSUInteger imageMaxCount;

/** 사진선택 전체최대개수 */
@property (nonatomic) NSUInteger imageTotalMaxCount;

@end


/**
 이미지 픽커컨트롤러 델리게이트
 */
@protocol ImagePickerControllerDelegate <NSObject>
@required
/**
 이미지 선택 완료시
 @param assets 선택된 에셋 리스트
 */
- (void)ImagePickerController:(ImagePickerController *)imagePickerController didFinishPickingAssets:(NSArray<PHAsset *> *)assets;
@optional
/**
 이미지 선택 취소시
 */
- (void)ImagePickerControllerDidCancel:(ImagePickerController *)imagePickerController;
@end

