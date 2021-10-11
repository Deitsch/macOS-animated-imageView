# macOS-animated-imageView
macOS has no implementation of ScaleToFill with keeping it's proportions on NSImageView. To do so CALayer is needed. This creates an issue when using gif which would need the `.animates = true` on the imageView. As workaround a `CAKeyframeAnimation` for the gif is generated and displayed on the covering layer instead
