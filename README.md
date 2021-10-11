# macOS-animated-imageView
macOS does not allow to ScaleToFill with keeping it's proportions. To do so CALayer is needed. This creates an issue when using gif which would need the `.animates = true` on the imageView. As workaround a `CAKeyframeAnimation` for the gif is generated and displayed on the covering layer instead
