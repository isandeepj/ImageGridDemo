//
//  ToastView.swift
//  ImageGridDemo
//
//  Created by Sandeep on 14/04/24.
//

import Foundation
import UIKit

enum HapticManager {
    case impact(UIImpactFeedbackGenerator.FeedbackStyle)
    case notification(UINotificationFeedbackGenerator.FeedbackType)
    case selection

    func generate() {
        guard #available(iOS 10, *) else { return }
        DispatchQueue.main.async {
            switch self {
            case .impact(let style):
                let generator = UIImpactFeedbackGenerator(style: style)
                generator.prepare()
                generator.impactOccurred()
            case .notification(let type):
                let generator = UINotificationFeedbackGenerator()
                generator.prepare()
                generator.notificationOccurred(type)
            case .selection:
                let generator = UISelectionFeedbackGenerator()
                generator.prepare()
                generator.selectionChanged()
            }
        }
    }
}
enum ToastType: Int {
    case good, bad, neutral
    var feedbackGeneratorType: HapticManager {
        switch self {
        case .good:
            return HapticManager.notification(.success)
        case .bad:
            return HapticManager.notification(.error)
        case .neutral:
            return HapticManager.notification(.warning)
        }
    }
    var backgroundColor: UIColor {
        switch self {
        case .good:
            return UIColor.green
        case .bad:
            return UIColor.red
        case .neutral:
            return UIColor.darkGray
        }
    }
}

class ToastView: UIView {
    lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 16)
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 0
        label.isUserInteractionEnabled = false
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    var handler: ((Toast?) -> Void)?
    var toast: Toast!
    var tapGestrure: UITapGestureRecognizer?
    convenience init(text: String, handler: ((Toast?) -> Void)? = nil) {
        self.init(frame: .zero)
        messageLabel.text = text
        self.handler = handler
        layout()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.darkGray
        clipsToBounds = true
        layer.cornerRadius = 0
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapped))
        addGestureRecognizer(tap)
        tapGestrure = tap
        isUserInteractionEnabled = true
    }

    func layout() {
        addSubview(messageLabel)
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        let insets = App.safeAreaInsets
        let top = max(insets.top+5, 20)

        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: topAnchor, constant: top),
            messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
            messageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -15),
            messageLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 24)
        ])


    }
    @objc func tapped() {
        handler?(nil)
        handler = nil
        if let getsture = tapGestrure {
            removeGestureRecognizer(getsture)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

struct Toast {
    var text: String
    var type: ToastType
    var duration: TimeInterval
    var handler: ((Toast?) -> Void)?
}

