

#import "ImagePickerController.h"
#import "ImagePickerGridHeaderView.h"
#import "ImagePickerGridViewCell.h"
#import "ImagePickerAlbumListViewCell.h"
#import "WebViewController.h"
#import "AppDelegate.h"
// String
#define STRING_APPNAME            NSLocalizedString(@"APPNAME", nil)
#define STRING_PROGRESS_LOADING    NSLocalizedString(@"PROGRESS_LOADING", nil)
#define STRING_BUTTON_OK        NSLocalizedString(@"BUTTON_OK", nil)
#define STRING_BUTTON_CANCEL    NSLocalizedString(@"BUTTON_CANCEL", nil)
#define STRING_BUTTON_AGREE        NSLocalizedString(@"BUTTON_AGREE", nil)
#define STRING_BUTTON_DISAGREE    NSLocalizedString(@"BUTTON_DISAGREE", nil)
#define STRING_BUTTON_SETTING    NSLocalizedString(@"BUTTON_SETTING", nil)

#define COLUMN_COUNT    3
#define CELL_SPACING    2

#define STRING_ALERT_ICLOUDSYNC        @"iCloud 사진 보관함에서 원본 사진을 다운로드 중입니다. 다운로드가 완료된 후 다시 시도해 주세요."


@interface NSIndexSet (Convenience)
- (NSArray *)aapl_indexPathsFromIndexesWithSection:(NSUInteger)section;
@end
@implementation NSIndexSet (Convenience)
- (NSArray *)aapl_indexPathsFromIndexesWithSection:(NSUInteger)section {
    NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:self.count];
    [self enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [indexPaths addObject:[NSIndexPath indexPathForItem:idx inSection:section]];
    }];
    return indexPaths;
}
@end


@interface UICollectionView (Convenience)
- (NSArray *)aapl_indexPathsForElementsInRect:(CGRect)rect;
@end
@implementation UICollectionView (Convenience)
- (NSArray *)aapl_indexPathsForElementsInRect:(CGRect)rect {
    NSArray *allLayoutAttributes = [self.collectionViewLayout layoutAttributesForElementsInRect:rect];
    if (allLayoutAttributes.count == 0) { return nil; }
    NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:allLayoutAttributes.count];
    for (UICollectionViewLayoutAttributes *layoutAttributes in allLayoutAttributes) {
        NSIndexPath *indexPath = layoutAttributes.indexPath;
        [indexPaths addObject:indexPath];
    }
    return indexPaths;
}
@end


@interface ImagePickerController () <UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UIScrollViewDelegate, PHPhotoLibraryChangeObserver>

// IBOutlet
@property (weak, nonatomic) IBOutlet UIButton *albumListButton;
@property (weak, nonatomic) IBOutlet UIImageView *albumListButtonArrow;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UITableView *albumListView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *albumListViewCenterYConstraint;

// ui
@property (nonatomic, strong) UICollectionViewFlowLayout *collectionViewFlowLayout;

// public
@property (nonatomic, strong, readwrite) NSMutableArray<PHAsset *> *selectedAssets;

// common
@property (nonatomic, strong) PHFetchOptions *fetchOptionsByStartDate;
@property (nonatomic, strong) PHFetchOptions *fetchOptionsByCreationDate;
@property (nonatomic, strong) PHFetchOptions *fetchOptionsByLocalizedTitle;
@property (nonatomic, strong) NSDateFormatter *dateFormatterForGridHeader;

// icloud
@property (nonatomic, strong) NSMutableArray<PHAsset *> *icloudDownloadingAssets;
@property (nonatomic, strong) NSMutableDictionary *icloudDownloadingProgressDictionary;

// albums
@property (nonatomic, assign) BOOL momentsLoading;
@property (nonatomic, assign) NSUInteger momentsCount;
@property (nonatomic, strong) PHFetchResult *momentsFetchResult;
@property (nonatomic, strong) NSMutableArray<PHAssetCollection *> *moments;
@property (nonatomic, strong) NSMutableArray<PHFetchResult *> *momentsFetchResults;
@property (nonatomic, strong) NSMutableArray<PHAssetCollection *> *smartAlbums;
@property (nonatomic, strong) NSMutableArray<PHFetchResult *> *smartAlbumsFetchResults;
@property (nonatomic, strong) NSMutableArray<PHAssetCollection *> *userAlbums;
@property (nonatomic, strong) NSMutableArray<PHFetchResult *> *userAlbumsFetchResults;

// temp
@property (nonatomic, strong) PHFetchResult *selectedAlbumFetchResult;

// Photos.framework
@property (nonatomic, strong) PHCachingImageManager *imageManager;
@property CGRect previousPreheatRect;

@end


@implementation ImagePickerController

static NSString * const CellReuseIdentifier = @"ImagePickerGridViewCell";
static CGSize AssetGridThumbnailSize;
static CGSize AssetGridHeaderSize;

- (void)awakeFromNib {
    //NSLogI();
    
    // init
    self.selectedAssets = [NSMutableArray new];
    self.icloudDownloadingAssets = [NSMutableArray new];
    self.icloudDownloadingProgressDictionary = [NSMutableDictionary new];
    
    // common
    self.dateFormatterForGridHeader = [NSDateFormatter new];
    [self.dateFormatterForGridHeader setDateFormat:@"yyyy. MM. dd."];
    
    // fetch options
    self.fetchOptionsByCreationDate = [[PHFetchOptions alloc] init];
    self.fetchOptionsByCreationDate.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    
    self.fetchOptionsByLocalizedTitle = [[PHFetchOptions alloc] init];
    self.fetchOptionsByLocalizedTitle.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"localizedTitle" ascending:YES],];
    
    self.fetchOptionsByStartDate = [[PHFetchOptions alloc] init];
    self.fetchOptionsByStartDate.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"startDate" ascending:NO]];
    
    // load data
    [self reloadData];
    
    // init photos framework
    self.imageManager = [[PHCachingImageManager alloc] init];
    [self resetCachedAssets];
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
}

- (void)viewDidLoad {
    //NSLogI();
    
    [super viewDidLoad];
    
    // moments loading
    if (self.momentsLoading) {
        self.albumListButton.userInteractionEnabled = NO;
        self.albumListButton.alpha = 0.5f;
        self.albumListButtonArrow.alpha = 0.5f;
    }
    
    // collection view
    self.collectionViewFlowLayout = ((UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout);
    self.collectionView.allowsMultipleSelection = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    //NSLogI();
    [super viewWillAppear:animated];
    
    //count
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app.imgdata removeAllObjects];
    self.imageMaxCount = app.ableImageCount;
    self.imageTotalMaxCount = app.maxImageCount;
    // config
    self.collectionViewFlowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    self.collectionViewFlowLayout.minimumLineSpacing = CELL_SPACING;
    self.collectionViewFlowLayout.minimumInteritemSpacing = CELL_SPACING;
    
    CGFloat itemWidth = floorf(([UIScreen mainScreen].bounds.size.width - (self.collectionViewFlowLayout.sectionInset.left + self.collectionViewFlowLayout.sectionInset.right) - (CELL_SPACING * (COLUMN_COUNT - 1))) / (float)COLUMN_COUNT);
    self.collectionViewFlowLayout.itemSize = CGSizeMake(itemWidth, itemWidth);
    
    //CGFloat scale = [UIScreen mainScreen].scale;
    CGFloat scale = 1.0f;
    CGSize cellSize = self.collectionViewFlowLayout.itemSize;
    AssetGridThumbnailSize = CGSizeMake(cellSize.width * scale, cellSize.height * scale);
    
    AssetGridHeaderSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, 30);
    
    // data
    [self.albumListView reloadData];
    
    // default album select
    if (self.selectedAlbumFetchResult == nil) {
        [self defaultAlbumSelect];
    }
    [self toggleAlbumList];
}

- (void)viewDidAppear:(BOOL)animated {
    //NSLogI();
    [super viewDidAppear:animated];
    
    // Begin caching assets in and around collection view's visible rect.
    [self updateCachedAssets];
}

- (void)didReceiveMemoryWarning {
    //NSLogW();
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    //NSLogE();
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}




#pragma mark - IBAction
- (IBAction)onCancelButtonClick:(UIButton *)sender {
    
    
    [self dismissViewControllerAnimated:YES completion:^{
        // delegate
        if (self.delegate && [self.delegate conformsToProtocol:@protocol(ImagePickerControllerDelegate)]) {
            [self.delegate ImagePickerControllerDidCancel:self];
        }
    }];
}




- (IBAction)onDoneButtonClick:(UIButton *)sender {
    //  NSLog(@"done%@",self.selectedAssets[0]);
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
        
        // sync
        option.synchronous = YES;
        
        
        
        // image resize
        option.resizeMode = PHImageRequestOptionsResizeModeExact;
        option.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        
        
        for (PHAsset *asset in self.selectedAssets) {
            
            
            @autoreleasepool {
                // get image
                __block UIImage *image = nil;
                
                [[PHImageManager defaultManager] requestImageForAsset:asset
                                                           targetSize:IMAGEUPLOAD_MINSIZE
                                                          contentMode:PHImageContentModeAspectFit
                                                              options:option
                                                        resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                                            
                                                            image = result;
                                                        }];
                
                
                
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
            }
        }
        
    });
    
    
    
    
    
    [self dismissViewControllerAnimated:YES completion:^{
        // delegate
        if (self.delegate && [self.delegate conformsToProtocol:@protocol(ImagePickerControllerDelegate)]) {
            
            [self.delegate ImagePickerController:self didFinishPickingAssets:self.selectedAssets];
        }
    }];
}

- (IBAction)onAlbumListButtonClick:(UIButton *)sender {
    [self toggleAlbumList];
}


#pragma mark - methods
- (void)reloadData {
    //NSLogD();
    //    NSLogD(@"self.isViewLoaded : %@", PrintBool(self.isViewLoaded));
    
    // init
    self.selectedAssets = [NSMutableArray new];
    self.selectedAlbumFetchResult = nil;
    
    // view
    if (self.isViewLoaded) {
        self.albumListButton.userInteractionEnabled = NO;
        self.albumListButton.alpha = 0.5;
        self.albumListButtonArrow.alpha = 0.5;
    }
    
    // get all photos
    //self.allPhotos = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:self.fetchOptionsByCreationDate];
    
    // get moments
    self.momentsLoading = YES;
    self.moments = [NSMutableArray new];
    self.momentsFetchResults = [NSMutableArray new];
    self.momentsCount = 0;
    self.momentsFetchResult = [PHAssetCollection fetchMomentsWithOptions:self.fetchOptionsByStartDate];
    //    NSLogD(@"self.momentsFetchResult : %d", (int)self.momentsFetchResult.count);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (PHAssetCollection *moment in self.momentsFetchResult) {
            PHFetchOptions *options = [[PHFetchOptions alloc] init];
            options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
            options.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d",PHAssetMediaTypeImage];
            PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:moment options:options];
            if (result.count != 0) {
                [self.moments addObject:moment];
                [self.momentsFetchResults addObject:result];
                self.momentsCount += result.count;
            }
            //NSLogD(@"moment : %@ %d", moment.localizedTitle, (int)result.count);
        }
        //NSLogD(@"self.momentsCount : %d", (int)self.momentsCount);
        
        dispatch_async(dispatch_get_main_queue(), ^ {
            self.momentsLoading = NO;
            self.albumListButton.userInteractionEnabled = YES;
            self.albumListButton.alpha = 1.0;
            self.albumListButtonArrow.alpha = 1.0;
            [self.albumListView reloadData];
        });
    });
    
    // get smart album
    self.smartAlbums = [NSMutableArray new];
    self.smartAlbumsFetchResults = [NSMutableArray new];
    PHFetchResult *smartAlbumsResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:self.fetchOptionsByLocalizedTitle];
    PHFetchOptions *smartAlbumsFetchOptions = [[PHFetchOptions alloc] init];
    smartAlbumsFetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO], [NSSortDescriptor sortDescriptorWithKey:@"modificationDate" ascending:NO]];
    smartAlbumsFetchOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d",PHAssetMediaTypeImage];
    for (NSInteger i = 0; i < smartAlbumsResult.count; i++) {
        PHAssetCollection *assetCollection = smartAlbumsResult[i];
        PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:assetCollection options:smartAlbumsFetchOptions];
        NSLog(@"sub album title is %@, count is %d %d %d", assetCollection.localizedTitle, (int)result.count, (int)assetCollection.assetCollectionType, (int)assetCollection.assetCollectionSubtype);
        
        if (result.count != 0) {
            // '모든 사진' 맨위로
            if (assetCollection.assetCollectionType == PHAssetCollectionTypeSmartAlbum &&
                assetCollection.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumUserLibrary) {
                [self.smartAlbums insertObject:assetCollection atIndex:0];
                [self.smartAlbumsFetchResults insertObject:result atIndex:0];
            }
            // '최근 삭제된 항목', ... 추가안함
            else if (assetCollection.assetCollectionType == PHAssetCollectionTypeSmartAlbum &&
                     assetCollection.assetCollectionSubtype == 1000000201) {
            }
            // 그 외 앨범 추가
            else {
                [self.smartAlbums addObject:assetCollection];
                [self.smartAlbumsFetchResults addObject:result];
            }
        }
    }
    
    // get user album
    self.userAlbums = [NSMutableArray new];
    self.userAlbumsFetchResults = [NSMutableArray new];
    PHFetchResult *userAlbumsResult = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:self.fetchOptionsByLocalizedTitle];
    PHFetchOptions *userAlbumsFetchOptions = [[PHFetchOptions alloc] init];
    userAlbumsFetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO], [NSSortDescriptor sortDescriptorWithKey:@"modificationDate" ascending:NO]];
    userAlbumsFetchOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d",PHAssetMediaTypeImage];
    for (NSInteger i = 0; i < userAlbumsResult.count; i++) {
        
        if ([userAlbumsResult[i] isMemberOfClass:[PHAssetCollection class]]) {
            PHAssetCollection *assetCollection = userAlbumsResult[i];
            PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:assetCollection options:userAlbumsFetchOptions];
            NSLog(@"[PHAssetCollection] %@, count is %d // %d %d", assetCollection.localizedTitle, (int)result.count, (int)assetCollection.assetCollectionType, (int)assetCollection.assetCollectionSubtype);
            
            if (result.count != 0) {
                [self.userAlbums addObject:assetCollection];
                [self.userAlbumsFetchResults addObject:result];
            }
        }
        else if ([userAlbumsResult[i] isMemberOfClass:[PHCollectionList class]]) {
            PHCollectionList *assetCollection = userAlbumsResult[i];
            PHFetchResult *result = [PHCollection fetchCollectionsInCollectionList:assetCollection options:nil];
            NSLog(@"[PHCollectionList] %@, count is %d // %d %d", assetCollection.localizedTitle, (int)result.count, (int)assetCollection.collectionListType, (int)assetCollection.collectionListSubtype);
            
            if (result.count != 0) {
                // 'iPhoto 이벤트'
                if (assetCollection.collectionListType == PHCollectionListTypeFolder &&
                    assetCollection.collectionListSubtype == PHCollectionListSubtypeRegularFolder) {
                    // TODO:
                }
            }
        }
    }
    
    // reload
    if (self.isViewLoaded) {
        // default select
        if (self.selectedAlbumFetchResult == nil) {
            [self defaultAlbumSelect];
        }
    }
}

- (void)defaultAlbumSelect {
    //NSLogD();
    if (self.smartAlbums.count > 0) {
        [self tableView:self.albumListView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
    }
    else {
        [self tableView:self.albumListView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    }
}

- (void)toggleAlbumList {
    
    if (self.albumListViewCenterYConstraint.priority == UILayoutPriorityDefaultHigh) {
        self.albumListViewCenterYConstraint.priority = UILayoutPriorityDefaultLow;
        self.albumListButtonArrow.highlighted = NO;
    }
    else {
        self.albumListViewCenterYConstraint.priority = UILayoutPriorityDefaultHigh;
        self.albumListButtonArrow.highlighted = YES;
    }
    [UIView animateWithDuration:VIEW_ANIMATION_DURATION animations:^{
        [self.albumListView layoutIfNeeded];
    } completion:^(BOOL finished) {
        
    }];
}

- (void)closeAlbumList {
    if (self.albumListViewCenterYConstraint.priority == UILayoutPriorityDefaultHigh) {
        self.albumListViewCenterYConstraint.priority = UILayoutPriorityDefaultLow;
        self.albumListButtonArrow.highlighted = NO;
        [UIView animateWithDuration:VIEW_ANIMATION_DURATION animations:^{
            [self.albumListView layoutIfNeeded];
        } completion:^(BOOL finished) {
            
        }];
    }
}

- (void)updateSelectionOrderLabels {
    NSArray<NSIndexPath *> *indexPathsForVisibleItems = self.collectionView.indexPathsForVisibleItems;
    for (NSIndexPath *indexPath in self.collectionView.indexPathsForSelectedItems) {
        if ([indexPathsForVisibleItems containsObject:indexPath]) {
            PHAsset *asset;
            if (self.selectedAlbumFetchResult == self.momentsFetchResult) {
                asset = self.momentsFetchResults[indexPath.section][indexPath.item];
            }
            else {
                asset = self.selectedAlbumFetchResult[indexPath.item];
            }
            
            ImagePickerGridViewCell *cell = (ImagePickerGridViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
            cell.selectionIndex = (self.imageTotalMaxCount - self.imageMaxCount) + [self.selectedAssets indexOfObject:asset];
        }
    }
}

- (void)updateICloudDownloadProgress {
    NSArray<NSIndexPath *> *indexPathsForVisibleItems = self.collectionView.indexPathsForVisibleItems;
    for (NSIndexPath *indexPath in indexPathsForVisibleItems) {
        PHAsset *asset = self.selectedAlbumFetchResult[indexPath.item];
        ImagePickerGridViewCell *cell = (ImagePickerGridViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
        
        if ([self.icloudDownloadingProgressDictionary.allKeys containsObject:asset]) {
            CGFloat progress = [[self.icloudDownloadingProgressDictionary objectForKey:asset] floatValue];
            cell.progressView.hidden = NO;
            [cell.progressView setProgress:progress animated:(progress != 0)];
        }
        else {
            cell.progressView.hidden = YES;
        }
    }
}

- (void)checkiCloudAsset:(PHAsset *)asset {
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.networkAccessAllowed = NO;
    [self.imageManager requestImageDataForAsset:asset
                                        options:options
                                  resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                                      //  NSLogD(@"info : %@", info);
                                      //  NSLogD(@"imageData : %@", imageData);
                                      if ([info valueForKey:PHImageResultIsInCloudKey]) {
                                          // need download
                                          if (imageData == nil) {
                                              [self.icloudDownloadingAssets addObject:asset];
                                              [self.icloudDownloadingProgressDictionary setObject:[NSNumber numberWithFloat:0] forKey:asset];
                                              
                                              [self updateICloudDownloadProgress];
                                              
                                              //      NSLogD(@"download start");
                                              PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
                                              option.synchronous = NO;
                                              option.networkAccessAllowed = YES;
                                              option.progressHandler = ^(double progress, NSError *__nullable error, BOOL *stop, NSDictionary *__nullable info){
                                                  //      NSLogW(@"info : %@", info);
                                                  //      NSLogW(@"progress : %f", progress);
                                                  
                                                  if (progress == 1.0f) {
                                                      [self.icloudDownloadingAssets removeObject:asset];
                                                      [self.icloudDownloadingProgressDictionary removeObjectForKey:asset];
                                                  }
                                                  else {
                                                      [self.icloudDownloadingProgressDictionary setObject:[NSNumber numberWithFloat:progress] forKey:asset];
                                                  }
                                                  
                                                  [self updateICloudDownloadProgress];
                                              };
                                              
                                              [[PHImageManager defaultManager] requestImageForAsset:asset
                                                                                         targetSize:IMAGEUPLOAD_MINSIZE
                                                                                        contentMode:PHImageContentModeAspectFit
                                                                                            options:option
                                                                                      resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                                                                          //  NSLogD(@"result : %@", result);
                                                                                          //  NSLogD(@"info : %@", info);
                                                                                      }];
                                          }
                                      }
                                  }];
}


#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"find11");
    if (section == 0) {
        return 1;
    }
    else if (section == 1) {
        return self.smartAlbums.count;
    }
    else if (section == 2) {
        return self.userAlbums.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"find12");
    static NSString *ImagePickerAlbumListViewCellIdentifier = @"ImagePickerAlbumListViewCell";
    ImagePickerAlbumListViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ImagePickerAlbumListViewCellIdentifier];
    PHAsset *asset = nil;
    
    cell.representedAssetIdentifier = nil;
    cell.albumImageView.contentMode = UIViewContentModeCenter;
    cell.albumImageView.image = [UIImage imageNamed:@"picker_album_placeholder"];
    
    if (indexPath.section == 0) {
        //        cell.backgroundColor = [UIColor whiteColor];
        //        cell.albumTitleLabel.text = @"모든 사진";
        //        cell.albumImageCountLabel.text = [NSString stringWithFormat:@"%d", (int)self.allPhotos.count];
        //
        //        if (self.allPhotos.count > 0) {
        //            asset = self.allPhotos[0];
        //        }
        
        cell.albumTitleLabel.text = @"특별한 순간";
        cell.albumImageCountLabel.text = [NSString stringWithFormat:@"%d", (int)self.momentsCount];
        
        if (self.momentsFetchResults.count > 0) {
            PHFetchResult *result = self.momentsFetchResults[0];
            if (result.count > 0) {
                asset = result[0];
            }
        }
    }
    else if (indexPath.section == 1) {
        PHAssetCollection *collection = self.smartAlbums[indexPath.row];
        PHFetchResult *result = self.smartAlbumsFetchResults[indexPath.row];
        cell.albumTitleLabel.text = collection.localizedTitle;
        cell.albumImageCountLabel.text = [NSString stringWithFormat:@"%d", (int)result.count];
        
        if (result.count > 0) {
            asset = result[0];
        }
    }
    else if (indexPath.section == 2) {
        PHCollection *collection = self.userAlbums[indexPath.row];
        cell.albumTitleLabel.text = collection.localizedTitle;
        if ([collection isMemberOfClass:[PHAssetCollection class]]) {
            PHFetchResult *result = self.userAlbumsFetchResults[indexPath.row];
            cell.albumImageCountLabel.text = [NSString stringWithFormat:@"%d", (int)result.count];
            
            if (result.count > 0) {
                asset = result[0];
            }
        }
        else if ([collection isMemberOfClass:[PHCollectionList class]]) {
            //            PHFetchResult *result = [PHCollection fetchCollectionsInCollectionList:(PHCollectionList *)collection options:nil];
            //            cell.albumImageCountLabel.text = [NSString stringWithFormat:@"%d", (int)result.count];
            //
            //            if (result.count > 0) {
            //                PHAssetCollection *collection2 = result[0];
            //                PHFetchResult *result2 = [PHAsset fetchAssetsInAssetCollection:collection2 options:self.fetchOptionsByCreationDate];
            //                if (result2.count > 0) {
            //                    asset = result2[0];
            //                }
            //            }
        }
    }
    
    // image
    if (asset) {
        NSLog(@"find13");
        cell.representedAssetIdentifier = asset.localIdentifier;
        cell.imageRequestID = [self.imageManager requestImageForAsset:asset
                                                           targetSize:cell.albumImageView.bounds.size
                                                          contentMode:PHImageContentModeAspectFill
                                                              options:nil
                                                        resultHandler:^(UIImage *result, NSDictionary *info) {
                                                            // Set the cell's thumbnail image if it's still showing the same asset.
                                                            if ([cell.representedAssetIdentifier isEqualToString:asset.localIdentifier]) {
                                                                cell.albumImageView.contentMode = UIViewContentModeScaleAspectFill;
                                                                cell.albumImageView.image = result;
                                                            }
                                                            cell.imageRequestID = -1;
                                                        }];
    }
    
    return cell;
}


#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //NSLog(@"%@", indexPath);
    NSLog(@"find14");
    ImagePickerAlbumListViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    // deselect
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // close
    [self closeAlbumList];
    
    // assets clear
    [self.selectedAssets removeAllObjects];
    [self.icloudDownloadingAssets removeAllObjects];
    [self.icloudDownloadingProgressDictionary removeAllObjects];
    
    // select album
    self.selectedAlbumFetchResult = nil;
    if (indexPath.section == 0) {
        //self.assetsFetchResults = self.allPhotos;
        self.selectedAlbumFetchResult = self.momentsFetchResult;
    }
    else if (indexPath.section == 1) {
        PHFetchResult *result = self.smartAlbumsFetchResults[indexPath.row];
        self.selectedAlbumFetchResult = result;
    }
    else if (indexPath.section == 2) {
        PHCollection *collection = self.userAlbums[indexPath.row];
        if ([collection isMemberOfClass:[PHAssetCollection class]]) {
            PHFetchResult *result = self.userAlbumsFetchResults[indexPath.row];
            self.selectedAlbumFetchResult = result;
        }
        else if ([collection isMemberOfClass:[PHCollectionList class]]) {
            PHFetchResult *result = [PHCollection fetchCollectionsInCollectionList:(PHCollectionList *)collection options:nil];
            self.selectedAlbumFetchResult = result;
        }
    }
    [self.collectionView reloadData];
    [self.collectionView setContentOffset:CGPointZero animated:NO];
    
    // album title
    [self.albumListButton setTitle:cell.albumTitleLabel.text forState:UIControlStateNormal];
}


#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    NSLog(@"find15");
    if (self.selectedAlbumFetchResult == self.momentsFetchResult) {
        return self.moments.count;
    }
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSLog(@"find16");
    //NSLog(@"count : %d", [self.selectedAlbumFetchResult countOfAssetsWithMediaType:PHAssetMediaTypeUnknown]);
    //NSLog(@"self.selectedAlbumFetchResult : %d", (int)self.selectedAlbumFetchResult.count);
    if (self.selectedAlbumFetchResult == self.momentsFetchResult) {
        return self.momentsFetchResults[section].count;
    }
    return self.selectedAlbumFetchResult.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(nonnull UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if (self.selectedAlbumFetchResult == self.momentsFetchResult) {
        return AssetGridHeaderSize;
    }
    return CGSizeZero;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    static NSString *ImagePickerGridHeaderViewIdentifier = @"ImagePickerGridHeaderView";
    NSLog(@"find17");
    UICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionHeader) {
        ImagePickerGridHeaderView *headerView = (ImagePickerGridHeaderView *)[collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:ImagePickerGridHeaderViewIdentifier forIndexPath:indexPath];
        
        if (self.selectedAlbumFetchResult == self.momentsFetchResult) {
            PHAssetCollection *moment = self.moments[indexPath.section];
            NSString *title = @"";
            if (moment.localizedTitle) {
                title = moment.localizedTitle;
            }
            else if (moment.startDate) {
                title = [self.dateFormatterForGridHeader stringFromDate:moment.startDate];
            }
            headerView.titleLabel.text = title;
        }
        
        reusableview = headerView;
    }
    
    return reusableview;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"find18");
    PHAsset *asset;
    if (self.selectedAlbumFetchResult == self.momentsFetchResult) {
        asset = self.momentsFetchResults[indexPath.section][indexPath.item];
    }
    else {
        asset = self.selectedAlbumFetchResult[indexPath.item];
    }
    //NSLogD(@"indexPath.item : %d", (int)indexPath.item);
    //NSLogD(@"asset : %@", asset);
    
    //    if ([asset isKindOfClass:[PHAssetCollection class]]) {
    //        PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:(PHAssetCollection *)asset options:nil];
    //        NSLogE(@"result.count : %d", (int)result.count);
    //        if (result.count > 0) {
    //            asset = result[0];
    //        }
    //    }
    
    // Dequeue an AAPLGridViewCell.
    ImagePickerGridViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellReuseIdentifier forIndexPath:indexPath];
    cell.representedAssetIdentifier = asset.localIdentifier;
    cell.selected = [self.selectedAssets containsObject:asset];
    if (cell.selected) {
        cell.selectionIndex = [self.selectedAssets indexOfObject:asset];
    }
    else {
        cell.selectionIndex = -1;
    }
    if ([self.icloudDownloadingProgressDictionary.allKeys containsObject:asset]) {
        CGFloat progress = [[self.icloudDownloadingProgressDictionary objectForKey:asset] floatValue];
        cell.progressView.hidden = NO;
        [cell.progressView setProgress:progress animated:NO];
    }
    else {
        cell.progressView.hidden = YES;
    }
    
    // Request an image for the asset from the PHCachingImageManager.
    cell.imageRequestID = [self.imageManager requestImageForAsset:asset
                                                       targetSize:AssetGridThumbnailSize
                                                      contentMode:PHImageContentModeAspectFill
                                                          options:nil
                                                    resultHandler:^(UIImage *result, NSDictionary *info) {
                                                        // Set the cell's thumbnail image if it's still showing the same asset.
                                                        if ([cell.representedAssetIdentifier isEqualToString:asset.localIdentifier]) {
                                                            cell.thumbnailImage = result;
                                                        }
                                                        cell.imageRequestID = -1;
                                                    }];
    //NSLogD(@"cell.imageRequestID : %d", cell.imageRequestID);
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    //NSLogD(@"indexPath.item : %d", (int)indexPath.item);
    ImagePickerGridViewCell *aCell = (ImagePickerGridViewCell *)cell;
    //NSLogD(@"cell.imageRequestID : %d", aCell.imageRequestID);
    if (aCell.imageRequestID != -1) {
        [self.imageManager cancelImageRequest:aCell.imageRequestID];
    }
}


#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"find6");
    //NSLogD(@"indexPath.item : %d", (int)indexPath.item);
    
    // check max count
    if (self.selectedAssets.count == self.imageMaxCount) {
        
        return;
    }
    
    PHAsset *asset;
    if (self.selectedAlbumFetchResult == self.momentsFetchResult) {
        asset = self.momentsFetchResults[indexPath.section][indexPath.item];
    }
    else {
        asset = self.selectedAlbumFetchResult[indexPath.item];
    }
    //NSLogD(@"asset : %@", asset);
    
    // check icloud
    //[self checkiCloudAsset:asset];
    
    [self.selectedAssets addObject:asset];
    
    [self updateSelectionOrderLabels];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"find5");
    //NSLogD(@"indexPath.item : %d", (int)indexPath.item);
    PHAsset *asset;
    if (self.selectedAlbumFetchResult == self.momentsFetchResult) {
        asset = self.momentsFetchResults[indexPath.section][indexPath.item];
    }
    else {
        asset = self.selectedAlbumFetchResult[indexPath.item];
    }
    
    ImagePickerGridViewCell *cell = (ImagePickerGridViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    
    [self.selectedAssets removeObject:asset];
    
    cell.selectionIndex = -1;
    
    [self updateSelectionOrderLabels];
}


#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSLog(@"find4");
    // Update cached assets for the new visible area.
    if (scrollView == self.collectionView) {
        [self updateCachedAssets];
    }
}


#pragma mark - PHPhotoLibraryChangeObserver
- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    NSLog(@"find3");
    //NSLogD();
    // Check if there are changes to the assets we are showing.
    PHFetchResultChangeDetails *collectionChanges = [changeInstance changeDetailsForFetchResult:self.selectedAlbumFetchResult];
    if (collectionChanges == nil) {
        return;
    }
    
    // reload
    dispatch_async(dispatch_get_main_queue(), ^ {
        [self reloadData];
    });
    
    /*
     Change notifications may be made on a background queue. Re-dispatch to the
     main queue before acting on the change as we'll be updating the UI.
     */
    dispatch_async(dispatch_get_main_queue(), ^{
        // Get the new fetch result.
        //        self.selectedAlbumFetchResult = [collectionChanges fetchResultAfterChanges];
        //
        //        UICollectionView *collectionView = self.collectionView;
        //
        //        if (![collectionChanges hasIncrementalChanges] || [collectionChanges hasMoves]) {
        //            // Reload the collection view if the incremental diffs are not available
        //            [collectionView reloadData];
        //
        //        } else {
        //            /*
        //             Tell the collection view to animate insertions and deletions if we
        //             have incremental diffs.
        //             */
        //            [collectionView performBatchUpdates:^{
        //                NSIndexSet *removedIndexes = [collectionChanges removedIndexes];
        //                if ([removedIndexes count] > 0) {
        //                    [collectionView deleteItemsAtIndexPaths:[removedIndexes aapl_indexPathsFromIndexesWithSection:0]];
        //                }
        //
        //                NSIndexSet *insertedIndexes = [collectionChanges insertedIndexes];
        //                if ([insertedIndexes count] > 0) {
        //                    [collectionView insertItemsAtIndexPaths:[insertedIndexes aapl_indexPathsFromIndexesWithSection:0]];
        //                }
        //
        //                NSIndexSet *changedIndexes = [collectionChanges changedIndexes];
        //                if ([changedIndexes count] > 0) {
        //                    [collectionView reloadItemsAtIndexPaths:[changedIndexes aapl_indexPathsFromIndexesWithSection:0]];
        //                }
        //            } completion:NULL];
        //        }
        
        [self resetCachedAssets];
    });
}


#pragma mark - Asset Caching
- (void)resetCachedAssets {
    //    NSLogD();
    [self.imageManager stopCachingImagesForAllAssets];
    self.previousPreheatRect = CGRectZero;
}

- (void)updateCachedAssets {
    //NSLogD();
    BOOL isViewVisible = [self isViewLoaded] && [[self view] window] != nil;
    if (!isViewVisible) { return; }
    
    // The preheat window is twice the height of the visible rect.
    CGRect preheatRect = self.collectionView.bounds;
    preheatRect = CGRectInset(preheatRect, 0.0f, -0.5f * CGRectGetHeight(preheatRect));
    
    /*
     Check if the collection view is showing an area that is significantly
     different to the last preheated area.
     */
    CGFloat delta = ABS(CGRectGetMidY(preheatRect) - CGRectGetMidY(self.previousPreheatRect));
    if (delta > CGRectGetHeight(self.collectionView.bounds) / 3.0f) {
        
        // Compute the assets to start caching and to stop caching.
        NSMutableArray *addedIndexPaths = [NSMutableArray array];
        NSMutableArray *removedIndexPaths = [NSMutableArray array];
        
        [self computeDifferenceBetweenRect:self.previousPreheatRect andRect:preheatRect removedHandler:^(CGRect removedRect) {
            NSArray *indexPaths = [self.collectionView aapl_indexPathsForElementsInRect:removedRect];
            [removedIndexPaths addObjectsFromArray:indexPaths];
        } addedHandler:^(CGRect addedRect) {
            NSArray *indexPaths = [self.collectionView aapl_indexPathsForElementsInRect:addedRect];
            [addedIndexPaths addObjectsFromArray:indexPaths];
        }];
        
        NSArray *assetsToStartCaching = [self assetsAtIndexPaths:addedIndexPaths];
        NSArray *assetsToStopCaching = [self assetsAtIndexPaths:removedIndexPaths];
        
        // Update the assets the PHCachingImageManager is caching.
        [self.imageManager startCachingImagesForAssets:assetsToStartCaching
                                            targetSize:AssetGridThumbnailSize
                                           contentMode:PHImageContentModeAspectFill
                                               options:nil];
        [self.imageManager stopCachingImagesForAssets:assetsToStopCaching
                                           targetSize:AssetGridThumbnailSize
                                          contentMode:PHImageContentModeAspectFill
                                              options:nil];
        
        // Store the preheat rect to compare against in the future.
        self.previousPreheatRect = preheatRect;
    }
}

- (void)computeDifferenceBetweenRect:(CGRect)oldRect andRect:(CGRect)newRect removedHandler:(void (^)(CGRect removedRect))removedHandler addedHandler:(void (^)(CGRect addedRect))addedHandler {
    if (CGRectIntersectsRect(newRect, oldRect)) {
        CGFloat oldMaxY = CGRectGetMaxY(oldRect);
        CGFloat oldMinY = CGRectGetMinY(oldRect);
        CGFloat newMaxY = CGRectGetMaxY(newRect);
        CGFloat newMinY = CGRectGetMinY(newRect);
        
        if (newMaxY > oldMaxY) {
            CGRect rectToAdd = CGRectMake(newRect.origin.x, oldMaxY, newRect.size.width, (newMaxY - oldMaxY));
            addedHandler(rectToAdd);
        }
        
        if (oldMinY > newMinY) {
            CGRect rectToAdd = CGRectMake(newRect.origin.x, newMinY, newRect.size.width, (oldMinY - newMinY));
            addedHandler(rectToAdd);
        }
        
        if (newMaxY < oldMaxY) {
            CGRect rectToRemove = CGRectMake(newRect.origin.x, newMaxY, newRect.size.width, (oldMaxY - newMaxY));
            removedHandler(rectToRemove);
        }
        
        if (oldMinY < newMinY) {
            CGRect rectToRemove = CGRectMake(newRect.origin.x, oldMinY, newRect.size.width, (newMinY - oldMinY));
            removedHandler(rectToRemove);
        }
    } else {
        addedHandler(newRect);
        removedHandler(oldRect);
    }
}

- (NSArray *)assetsAtIndexPaths:(NSArray *)indexPaths {
    NSLog(@"find2");
    if (indexPaths.count == 0) { return nil; }
    
    NSMutableArray *assets = [NSMutableArray arrayWithCapacity:indexPaths.count];
    for (NSIndexPath *indexPath in indexPaths) {
        PHAsset *asset;
        if (self.selectedAlbumFetchResult == self.momentsFetchResult) {
            asset = self.momentsFetchResults[indexPath.section][indexPath.item];
        }
        else {
            asset = self.selectedAlbumFetchResult[indexPath.item];
        }
        [assets addObject:asset];
    }
    
    return assets;
}
@end

