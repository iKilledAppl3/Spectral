//
//  SBBlurryArtworkView.m
//  BlurredLockscreenArtwork
//
//  Created by Adam Bell on 2014-01-03.
//  Copyright (c) 2014 Adam Bell. All rights reserved.
//

#import "SBBlurryArtworkView.h"

#import "PrivateHeaders.h"
#import <objc/runtime.h>

#define DEFAULT_BLUR_ZOOM 1.5
#define DEFAULT_BLUR_STYLE 5

#define DEFAULT_CROSSFADE_DURATION 0.3

@implementation SBBlurryArtworkView {
    SBFStaticWallpaperView *_wallpaperView;
    UIImageView *_imageView;

    UIImage *_artworkImage;

    float _zoomFactor;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        _imageView = [[UIImageView alloc] initWithFrame:frame];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        [self addSubview:_imageView];
    }

    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGRect bounds = self.bounds;

    CGRect imageViewFrame = bounds;
    imageViewFrame.size.width = floor(imageViewFrame.size.width * _zoomFactor);
    imageViewFrame.size.height = floor(imageViewFrame.size.height * _zoomFactor);
    imageViewFrame.origin.x = floor((bounds.size.width - imageViewFrame.size.width) / 2.0);
    imageViewFrame.origin.y = floor((bounds.size.height - imageViewFrame.size.height) / 2.0);
    _imageView.frame = imageViewFrame;
}

- (void)setArtworkImage:(UIImage *)artworkImage {
    if (_artworkImage == artworkImage)
        return;

    _artworkImage = artworkImage;

    if (_artworkImage != nil) {
        if (![artworkImage isKindOfClass:[UIImage class]]) {
            _artworkImage = nil;
        }
    }

    [self setZoomFactor:DEFAULT_BLUR_ZOOM andStyle:DEFAULT_BLUR_STYLE forImage:_artworkImage];
}

- (UIImage *)artworkImage {
    return _artworkImage;
}

- (void)setZoomFactor:(float)zoomFactor andStyle:(int)style forImage:(UIImage *)image {
    // On Styles...
    //
    // 0 No blur
    // 1 No blur
    // 2 Some blur, normal colour
    // 3 Barely any blur, normal colour
    // 4 Blurred more than 5 (they're super close), normal colour
    // 5 Blurred less than 4, darker, used on wallpapers (I think), so make it the default
    // 6 Similar to 5, lighter
    // 7 Blurred the most, lighter
    // 8 blur? what's a blur? let's use black

    UIImage *blurredImage = nil;

    if (image == nil || ![image isKindOfClass:[UIImage class]]) {
        blurredImage = nil;
    }
    else {
        SBWallpaperController *controller = [objc_getClass("SBWallpaperController") sharedInstance];
        _wallpaperView = [controller _newWallpaperViewForProcedural:nil orImage:image];

        // SBWallpaperController does some crazy shenanigans with subviews so let's remove that...
        [_wallpaperView removeFromSuperview];
        blurredImage = [objc_getClass("_SBFakeBlurView") _imageForStyle:&style withSource:_wallpaperView];
    }

    [UIView transitionWithView:_imageView
                      duration:DEFAULT_CROSSFADE_DURATION
                       options:UIViewAnimationOptionTransitionCrossDissolve
                   animations:^{
                                   _imageView.image = blurredImage;
                               }
                   completion:nil];

    _zoomFactor = zoomFactor;
    [self setNeedsLayout];
}

@end