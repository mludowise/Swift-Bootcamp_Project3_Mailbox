//
//  MailboxViewController.swift
//  Mailbox
//
//  Created by Mel Ludowise on 10/18/14.
//  Copyright (c) 2014 Mel Ludowise. All rights reserved.
//

import UIKit

class MailboxViewController: UIViewController {
    
    //    private let kDragThreshold1 = 0.25 * UIScreen.mainScreen().bounds.width
    //    private let kDragThreshold2 = 0.75 * UIScreen.mainScreen().bounds.width
    private let kDragThreshold1 : CGFloat = 70
    private let kDragThreshold2 : CGFloat = UIScreen.mainScreen().bounds.width - 70
    
    private enum SwipeAction {
        case LeftCancel     // User has not swiped left far enough to take any action
        case Schedule       // User swiped left to schedule
        case RightCancel    // User has not swiped right far enough to take any action
        case Archive        // User swiped right to archive
        case Delete         // User swiped right to delete
    }
    
    @IBOutlet weak var messageView: UIImageView!
    @IBOutlet weak var messageBackground: UIView!
    @IBOutlet weak var feedView: UIImageView!

    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resizeScrollViewForChildren(scrollView)
    }

    // Returns which action the user indends to take based how far they swiped
    // swipeDistance < 0 for Left & > 0 for Right
    private func getActionFromSwipe(swipeDistance: CGFloat) -> SwipeAction {
        if (swipeDistance < 0) { // Swipe left
            if (swipeDistance > -kDragThreshold1) { // Gray Schedule
                return .LeftCancel
            } else { // Yellow Schedule
                return .Schedule
            }
        } else { // Swipe right
            if (swipeDistance < kDragThreshold1) { // Gray archive
                return .RightCancel
            } else if (swipeDistance < kDragThreshold2) { // Green archive
                return .Archive
            } else { // Red Delete
                return .Delete
            }
        }
    }
    
    func removeRow() {
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.feedView.frame.origin.y -= self.messageView.frame.height
            }, completion: { (animate: Bool) -> Void in
                self.messageView.frame.origin.x = 0
                self.feedView.frame.origin.y += self.messageView.frame.height
        })
    }
    
    @IBAction func onMessagePan(panGestureRecognizer: UIPanGestureRecognizer) {
        //        var point = panGestureRecognizer.locationInView(view)
        var velocity = panGestureRecognizer.velocityInView(view)
        var translation = panGestureRecognizer.translationInView(messageView)
        
        var screenWidth = UIScreen.mainScreen().bounds.width
        
        var action = getActionFromSwipe(translation.x)
        
        if (panGestureRecognizer.state == UIGestureRecognizerState.Ended) {
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                switch (action) {
                case .Archive, .Delete:
                    self.messageView.frame.origin.x = screenWidth
                    break
                case .Schedule:
                    self.messageView.frame.origin.x = -self.messageView.frame.width
                    break
                default: // LeftCancel, RightCancel
                    self.messageView.frame.origin.x = 0
                }
                }, completion: { (animate: Bool) -> Void in
                    if (action != .LeftCancel && action != .RightCancel) {
                        self.removeRow()
                    }
            })
        } else {
            switch (action) {
            case .Archive:
                messageBackground.backgroundColor = UIColor.greenColor()
                break
            case .Delete:
                messageBackground.backgroundColor = UIColor.redColor()
                break
            case .Schedule:
                messageBackground.backgroundColor = UIColor.yellowColor()
                break
            default: // LeftCancel, RightCancel
                messageBackground.backgroundColor = UIColor.grayColor()
            }
            messageView.frame.origin.x = translation.x
        }
    }
}
