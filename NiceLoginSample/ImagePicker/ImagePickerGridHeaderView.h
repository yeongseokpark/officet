
#import <UIKit/UIKit.h>
////////////////////////////////////////////////////////////////////////////////////////////////////
// DEFINES
////////////////////////////////////////////////////////////////////////////////////////////////////
#define API_ENCODING                            NSUTF8StringEncoding                                // API 문자열 인코딩
#define API_LOADING_TIMEOUT                        20.0                                                // API 로딩 타임아웃(초단위)
#define WEBVIEW_LOADING_TIMEOUT                    20.0                                                // 웹뷰 로딩 타임아웃(초단위)
#define WEBVIEW_CACHE_EXPIRED_TIMEINTERVAL        10 * 60.0                                            // 웹뷰 캐시 기한(초단위)
#define WEBVIEW_BACKGROUND_COLOR                UIColorFromRGB(0xEEEEEE)                            // 웹뷰 백그라운드 컬러
#define REFRESHCONTROL_TINT_COLOR                UIColorFromRGB(0xFF4E00)                            // 웹뷰 리프레쉬컨트롤 틴트 컬러
#define VIEW_ANIMATION_DURATION                    0.3                                                    // 애니메이션 지속시간
#define LNB_MARGIN_RIGHT                        60                                                    // LNB Margin Right
#define IMAGEUPLOAD_MINSIZE                        CGSizeMake(750, 1054)                                // 이미지업로드 최소사이즈
#define IMAGEUPLOAD_JPEG_QUALITY                0.25                                                // 이미지업로드 jpeg 퀄리티
////////////////////////////////////////////////////////////////////////////////////////////////////

@interface ImagePickerGridHeaderView : UICollectionReusableView

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

