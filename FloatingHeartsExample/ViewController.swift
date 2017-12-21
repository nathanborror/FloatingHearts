//
//  ViewController.swift
//  FloatingHeartsExample
//
//  Created by Said Marouf on 4/20/16.
//  Copyright © 2016 Said Marouf. All rights reserved.
//

import UIKit
import FloatingHearts

class ViewController: UIViewController {

    private struct HeartAttributes {
        static let size = CGSize(width: 36, height: 36)
        static let burstDelay: TimeInterval = 0.1
    }

    private var burstTimer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(hex: 0xf2f4f6)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showTheLove))
        view.addGestureRecognizer(tapGesture)

        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress))
        longPressGesture.minimumPressDuration = 0.2
        view.addGestureRecognizer(longPressGesture)
    }

    @objc func didLongPress(recognizer: UILongPressGestureRecognizer) {
        switch recognizer.state {
        case .began:
            burstTimer = Timer.scheduledTimer(timeInterval: HeartAttributes.burstDelay, target: self, selector: #selector(showTheLove), userInfo: nil, repeats: true)
        case .ended, .cancelled:
            burstTimer?.invalidate()
        default:
            break
        }
    }

    @objc func showTheLove() {
        let heart = HeartView(frame: CGRect(origin: .zero, size: HeartAttributes.size))
        view.addSubview(heart)
        let fountainX = HeartAttributes.size.width / 2.0 + 20
        let fountainY = view.bounds.height - HeartAttributes.size.height / 2.0 - 10
        heart.center = CGPoint(x: fountainX, y: fountainY)
        heart.animateInView(view: view)
    }
}
