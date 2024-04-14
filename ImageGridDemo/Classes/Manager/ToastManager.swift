//
//  ToastManager.swift
//  ImageGridDemo
//
//  Created by Sandeep on 14/04/24.
//

import Foundation
import UIKit

class ToastManager: NSObject {
    static let shared = ToastManager()
    
    var toastQueue = Queue<Toast>()
    var isToasting = false
    static var notToasting: Bool {
        return !shared.isToasting
    }
    static var isToasting: Bool {
        return shared.isToasting
    }
    
    var lastToast: Toast?
    var currentToastView: ToastView?
    var currentWindow: UIWindow?
    var workItemAutoDismiss: DispatchWorkItem?
    
    override init() {
        super.init()
    }
    
    func toast() {
        guard !isToasting else {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {
                self.toast()
            })
            return
        }
        guard let toast = toastQueue.pop() else { return }
        
        lastToast = toast
        isToasting = true
        DispatchQueue.main.async {
            self.currentWindow = App.shared.window ?? UIApplication.shared.windows.first
            guard let currentWindow = self.currentWindow else { return }
            
            self.currentToastView = ToastView(text: toast.text, handler: toast.handler)
            guard let currentToastView = self.currentToastView else { return }
            currentToastView.alpha = 0
            currentToastView.isUserInteractionEnabled = true
            currentToastView.backgroundColor = toast.type.backgroundColor
            currentWindow.addSubview(currentToastView)
            currentToastView.layer.zPosition = 100
            currentWindow.layoutIfNeeded()
            
            currentToastView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                currentToastView.topAnchor.constraint(equalTo: currentWindow.topAnchor, constant: 0),
                currentToastView.leadingAnchor.constraint(equalTo: currentWindow.leadingAnchor, constant: 0),
                currentToastView.trailingAnchor.constraint(equalTo: currentWindow.trailingAnchor, constant: 0),
                currentToastView.heightAnchor.constraint(greaterThanOrEqualToConstant: 40)
            ])
            UIView.animate(withDuration: 0.25, delay: 0, options: .allowUserInteraction, animations: {
                self.currentToastView?.alpha = 1
            }, completion: {[weak self] _ in
                toast.type.feedbackGeneratorType.generate()
                self?.prepareAutoDismissToast(toast)
            })
        }
    }
    func prepareAutoDismissToast(_ toast: Toast) {
        var workItem: DispatchWorkItem!
        workItem = DispatchWorkItem { [weak self] in
            guard let newWorkItem = workItem, !newWorkItem.isCancelled, let weakSelf = self else { return }
            weakSelf.dismissToastAnimation()
        }
        self.workItemAutoDismiss = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + toast.duration, execute: workItem)
    }
    private func dismissToastAnimation() {
        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseOut, .allowUserInteraction], animations: {
            self.currentToastView?.alpha = 0
        }, completion: { [weak self] _ in
            self?.resetToast()
            self?.toast()
        })
    }
    private func resetToast() {
        currentToastView?.layer.removeAllAnimations()
        currentToastView?.removeFromSuperview()
        currentToastView = nil
        workItemAutoDismiss?.cancel()
        currentWindow = nil
        self.isToasting = false
    }
    
   static func showToast(text: String, type: ToastType = .neutral, duration: TimeInterval = 2.0, handler: ((Toast?) -> Void)? = nil) {
       guard !text.isEmpty, shared.toastQueue.first?.text != text else { return } // Prevent duplicate messages at least...
       let toast = Toast(text: text, type: type, duration: duration, handler: handler)

        DispatchQueue.main.async {
            shared.toastQueue.push(toast)
            shared.toast()
        }
    }
}
