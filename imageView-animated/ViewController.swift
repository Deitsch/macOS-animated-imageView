//
//  ViewController.swift
//  imageView-animated
//
//  Created by Simon Deutsch on 11.10.21.
//

import Cocoa
import AVFoundation
import CoreFoundation

class ViewController: NSViewController {

    @IBOutlet weak var imageView: NSImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let url = Bundle.main.url(forResource: "nyan", withExtension: "gif")!

//        imageImage(url: url)
        layerImage(url: url)
    }

    func layerImage(url: URL) {
        
        imageView.layer = CALayer()
        imageView.layer?.contentsGravity = CALayerContentsGravity.resizeAspectFill
        let animation = createGIFAnimation(url: url)!
        imageView.layer?.add(animation, forKey: "gif")
        imageView.wantsLayer = true
    }
    
    func imageImage(url: URL) {
        imageView.animates = true
        let data = try! Data(contentsOf: url)
        imageView.image = NSImage(data: data)
    }
}

func createGIFAnimation(url: URL) -> CAKeyframeAnimation? {

    guard let src = CGImageSourceCreateWithURL(url as CFURL, nil) else { return nil }
    let frameCount = CGImageSourceGetCount(src)

    // Total loop time
    var time : Float = 0

    // Arrays
    var framesArray = [AnyObject]()
    var tempTimesArray = [NSNumber]()

    // Loop
    for i in 0..<frameCount {

        // Frame default duration
        var frameDuration : Float = 0.1;

        let cfFrameProperties = CGImageSourceCopyPropertiesAtIndex(src, i, nil)
        guard let framePrpoerties = cfFrameProperties as? [String:AnyObject] else {return nil}
        guard let gifProperties = framePrpoerties[kCGImagePropertyGIFDictionary as String] as? [String:AnyObject]
            else { return nil }

        // Use kCGImagePropertyGIFUnclampedDelayTime or kCGImagePropertyGIFDelayTime
        if let delayTimeUnclampedProp = gifProperties[kCGImagePropertyGIFUnclampedDelayTime as String] as? NSNumber {
            frameDuration = delayTimeUnclampedProp.floatValue
        }
        else{
            if let delayTimeProp = gifProperties[kCGImagePropertyGIFDelayTime as String] as? NSNumber {
                frameDuration = delayTimeProp.floatValue
            }
        }

        // Make sure its not too small
        if frameDuration < 0.011 {
            frameDuration = 0.100;
        }

        // Add frame to array of frames
        if let frame = CGImageSourceCreateImageAtIndex(src, i, nil) {
            tempTimesArray.append(NSNumber(value: frameDuration))
            framesArray.append(frame)
        }

        // Compile total loop time
        time = time + frameDuration
    }

    var timesArray = [NSNumber]()
    var base : Float = 0
    for duration in tempTimesArray {
        timesArray.append(NSNumber(value: base))
        base += ( duration.floatValue / time )
    }

    // From documentation of 'CAKeyframeAnimation':
    // the first value in the array must be 0.0 and the last value must be 1.0.
    // The array should have one more entry than appears in the values array.
    // For example, if there are two values, there should be three key times.
    timesArray.append(NSNumber(value: 1.0))

    // Create animation
    let animation = CAKeyframeAnimation(keyPath: "contents")

    animation.beginTime = AVCoreAnimationBeginTimeAtZero
    animation.duration = CFTimeInterval(time)
    animation.repeatCount = Float.greatestFiniteMagnitude;
    animation.isRemovedOnCompletion = false
    animation.fillMode = CAMediaTimingFillMode.forwards
    animation.values = framesArray
    animation.keyTimes = timesArray
    //animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
    animation.calculationMode = CAAnimationCalculationMode.discrete

    return animation;
}
