//
//  ReactionView.swift
//  Reactions
//
//  Created by Said Marouf on 9/22/15.
//  Modified by Nathan Borror on 12/21/17
//  Copyright © 2015 Said Marouf. All rights reserved.
//

import UIKit

public class ReactionView: UIView {

    private enum Rotation: CGFloat {
        case left = -1
        case right = 1
    }

    private struct Durations {
        static let full: TimeInterval = 4.0
        static let bloom: TimeInterval = 0.5
    }

    public init(for view: UIView) {
        super.init(frame: CGRect(origin: .zero, size: view.bounds.size))
        backgroundColor = UIColor.clear
        layer.anchorPoint = CGPoint(x: 0.5, y: 1)
        addSubview(view)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func animate(in view: UIView) {
        guard let rotationDirection = Rotation(rawValue: CGFloat(1 - Int(2 * rand(2)))) else { return }
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

    private func performSlightRotationAnimation(direction: Rotation) {
        let rotationFraction = CGFloat(rand(10))
        UIView.animate(withDuration: Durations.full) {
            self.transform = CGAffineTransform(rotationAngle: direction.rawValue * .pi / (16 + rotationFraction * 0.2))
        }
    }

    private func travelPath(inView view: UIView) -> UIBezierPath? {
        guard let endPointDirection = Rotation(rawValue: CGFloat(1 - (2 * rand(2)))) else { return nil }

        let centerX = center.x
        let width = bounds.width
        let viewHeight = view.bounds.height

        // Random end point
        let endPointX = centerX + (endPointDirection.rawValue * rand(2 * width))
        let endPointY = viewHeight / 8.0 + rand(viewHeight / 4.0)
        let endPoint = CGPoint(x: endPointX, y: endPointY)

        // Random Control Points
        let travelDirection = CGFloat(1 - (2 * rand(2)))
        let xDelta = (width / 2.0 + rand(2 * width)) * travelDirection
        let yDelta = max(endPoint.y ,max(rand(8 * width), width))
        let controlPoint1 = CGPoint(x: centerX + xDelta, y: viewHeight - yDelta)
        let controlPoint2 = CGPoint(x: centerX - 2 * xDelta, y: yDelta)

        let path = UIBezierPath()
        path.move(to: center)
        path.addCurve(to: endPoint, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
        return path
    }

    private func addPathAnimation(inView view: UIView) {
        guard let travelPath = travelPath(inView: view) else { return }
        let keyFrameAnimation = CAKeyframeAnimation(keyPath: "position")
        keyFrameAnimation.path = travelPath.cgPath
        keyFrameAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        let durationAdjustment = 4 * TimeInterval(travelPath.bounds.height / view.bounds.height)
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
}

func rand(_ bound: Int) -> Int {
    return Int(arc4random_uniform(UInt32(bound)))
}

func rand(_ bound: CGFloat) -> CGFloat {
    return CGFloat(rand(Int(bound)))
}

