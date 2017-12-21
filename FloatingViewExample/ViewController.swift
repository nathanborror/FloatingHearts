//
//  ViewController.swift
//  FloatingViewExample
//
//  Created by Said Marouf on 4/20/16.
//  Copyright © 2016 Said Marouf. All rights reserved.
//

import UIKit
import FloatingView

class ViewController: UIViewController {

    private let burstDelay: TimeInterval = 0.1
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
            burstTimer = Timer.scheduledTimer(timeInterval: burstDelay, target: self, selector: #selector(showTheLove), userInfo: nil, repeats: true)
        case .ended, .cancelled:
            burstTimer?.invalidate()
        default:
            break
        }
    }

    @objc func showTheLove() {
        let heart = HeartTheme.randomTheme()
        let heartView = FloatingView(floater: heart)
        view.addSubview(heartView)

        let fountainX = (heartView.bounds.width / 2) + 20
        let fountainY = view.bounds.height - (heartView.bounds.size.height / 2)
        heartView.center = CGPoint(x: fountainX, y: fountainY)

        heartView.animateInView(view: view)
    }
}

struct HeartTheme: Floater {
    let fill: UIColor
    let stroke: UIColor

    let size = CGSize(width: 36, height: 36)
    let image = UIImage(named: "heart")?.withRenderingMode(.alwaysTemplate)
    let imageBorder = UIImage(named: "heartBorder")?.withRenderingMode(.alwaysTemplate)

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
        let randIndex = Int(arc4random_uniform(UInt32(availableThemes.count)))
        let theme = availableThemes[randIndex]
        return HeartTheme(fill: theme.0, stroke: theme.1)
    }
}

