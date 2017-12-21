//
//  HeartView.swift
//  FloatingHeart
//
//  Created by Said Marouf on 9/22/15.
//  Copyright © 2015 Said Marouf. All rights reserved.
//

import UIKit
import Foundation

struct HeartTheme {
    let fill: UIColor
    let stroke: UIColor

    // Using white borders for this example. Set your colors.
    static let availableThemes = [
        (UIColor(hex: 0xe66f5e), UIColor(white: 1.0, alpha: 0.8)),
        (UIColor(hex: 0x6a69a0), UIColor(white: 1.0, alpha: 0.8)),
        (UIColor(hex: 0x81cc88), UIColor(white: 1.0, alpha: 0.8)),
        (UIColor(hex: 0xfd3870), UIColor(white: 1.0, alpha: 0.8)),
        (UIColor(hex: 0x6ecff6), UIColor(white: 1.0, alpha: 0.8)),
        (UIColor(hex: 0xc0aaf7), UIColor(white: 1.0, alpha: 0.8)),
        (UIColor(hex: 0xf7603b), UIColor(white: 1.0, alpha: 0.8)),
        (UIColor(hex: 0x39d3d3), UIColor(white: 1.0, alpha: 0.8)),
        (UIColor(hex: 0xfed301), UIColor(white: 1.0, alpha: 0.8))
    ]

    static func randomTheme() -> HeartTheme {
        let theme = availableThemes[rand(availableThemes.count)]
        return HeartTheme(fill: theme.0, stroke: theme.1)
    }
}

public class HeartView: UIView {

    enum RotationDirection: CGFloat {
        case left = -1
        case right = 1
    }

    private struct Durations {
        static let full: TimeInterval = 4.0
        static let bloom: TimeInterval = 0.5
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
        layer.anchorPoint = CGPoint(x: 0.5, y: 1)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public func animateInView(view: UIView) {
        guard let rotationDirection = RotationDirection(rawValue: CGFloat(1 - Int(2 * rand(2)))) else { return }
        prepareForAnimation()
        performBloomAnimation()
        performSlightRotationAnimation(direction: rotationDirection)
        addPathAnimation(inView: view)
    }

    private func prepareForAnimation() {
        transform = CGAffineTransform(scaleX: 0, y: 0)
        alpha = 0
    }

    private func performBloomAnimation() {
        UIView.animate(withDuration: Durations.bloom, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: [UIViewAnimationOptions.curveEaseOut], animations: {
            self.transform = CGAffineTransform.identity
            self.alpha = 0.9
        }, completion: nil)
    }

    private func performSlightRotationAnimation(direction: RotationDirection) {
        let rotationFraction = CGFloat(rand(10))
        UIView.animate(withDuration: Durations.full) {
            self.transform = CGAffineTransform(rotationAngle: direction.rawValue * .pi / (16 + rotationFraction * 0.2))
        }
    }

    private func travelPath(inView view: UIView) -> UIBezierPath? {
        guard let endPointDirection = RotationDirection(rawValue: CGFloat(1 - (2 * rand(2)))) else { return nil }

        let heartCenterX = center.x
        let heartSize = bounds.width
        let viewHeight = view.bounds.height

        // Random end point
        let endPointX = heartCenterX + (endPointDirection.rawValue * rand(2 * heartSize))
        let endPointY = viewHeight / 8.0 + rand(viewHeight / 4.0)
        let endPoint = CGPoint(x: endPointX, y: endPointY)

        // Random Control Points
        let travelDirection = CGFloat(1 - (2 * rand(2)))
        let xDelta = (heartSize / 2.0 + rand(2 * heartSize)) * travelDirection
        let yDelta = max(endPoint.y ,max(rand(8 * heartSize), heartSize))
        let controlPoint1 = CGPoint(x: heartCenterX + xDelta, y: viewHeight - yDelta)
        let controlPoint2 = CGPoint(x: heartCenterX - 2 * xDelta, y: yDelta)

        let path = UIBezierPath()
        path.move(to: center)
        path.addCurve(to: endPoint, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
        return path
    }

    private func addPathAnimation(inView view: UIView) {
        guard let heartTravelPath = travelPath(inView: view) else { return }
        let keyFrameAnimation = CAKeyframeAnimation(keyPath: "position")
        keyFrameAnimation.path = heartTravelPath.cgPath
        keyFrameAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        let durationAdjustment = 4 * TimeInterval(heartTravelPath.bounds.height / view.bounds.height)
        let duration = Durations.full + durationAdjustment
        keyFrameAnimation.duration = duration
        layer.add(keyFrameAnimation, forKey: "positionOnPath")

        animateToFinalAlpha(withDuration: duration)
    }

    private func animateToFinalAlpha(withDuration duration: TimeInterval = Durations.full) {
        UIView.animate(withDuration: duration, animations: {
            self.alpha = 0.0
        }, completion: { finished in
            self.removeFromSuperview()
        })
    }

    public override func draw(_ rect: CGRect) {
        let theme = HeartTheme.randomTheme()
        let imageBundle = Bundle(for: HeartView.self)
        let heartImage = UIImage(named: "heart", in: imageBundle, compatibleWith: nil)
        let heartImageBorder = UIImage(named: "heartBorder", in: imageBundle, compatibleWith: nil)
    
        // Draw background image (mimics border)
        theme.stroke.setFill()
        heartImageBorder?.draw(in: rect, blendMode: .normal, alpha: 1.0)

        // Draw foreground heart image
        theme.fill.setFill()
        heartImage?.draw(in: rect, blendMode: .normal, alpha: 1.0)
    }
}

func rand(_ bound: Int) -> Int {
    return Int(arc4random_uniform(UInt32(bound)))
}

func rand(_ bound: CGFloat) -> CGFloat {
    return CGFloat(rand(Int(bound)))
}

