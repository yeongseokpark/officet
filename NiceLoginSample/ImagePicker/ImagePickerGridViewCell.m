

#import "ImagePickerGridViewCell.h"

@interface ImagePickerGridViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIView *selectedOverlayView;
@property (weak, nonatomic) IBOutlet UILabel *orderLabel;
@end

@implementation ImagePickerGridViewCell

- (void)awakeFromNib {
    self.selectedOverlayView.hidden = YES;
    self.progressView.hidden = YES;
    self.progressView.primaryColor = [UIColor whiteColor];
    self.progressView.secondaryColor = [UIColor whiteColor];
    self.progressView.backgroundRingWidth = 3;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.imageView.image = nil;
    self.imageRequestID = -1;
    self.selectedOverlayView.hidden = YES;
    self.progressView.hidden = YES;
    [self.progressView setProgress:0 animated:NO];
}

- (void)setThumbnailImage:(UIImage *)thumbnailImage {
    _thumbnailImage = thumbnailImage;
    self.imageView.image = thumbnailImage;
}

- (void)setSelectionIndex:(NSInteger)selectionIndex {
    _selectionIndex = selectionIndex;
    if (selectionIndex >= 0) {
        self.orderLabel.hidden = NO;
        self.orderLabel.text = [NSString stringWithFormat:@"%d", (int)selectionIndex + 1];
        self.orderLabel.layer.masksToBounds = YES;
        self.orderLabel.layer.cornerRadius = self.orderLabel.bounds.size.width / 2;
        self.selectedOverlayView.hidden = NO;
    }
    else {
        self.orderLabel.hidden = YES;
        self.selectedOverlayView.hidden = YES;
    }
}

@end

