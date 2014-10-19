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
    private let kDragThreshold1 : CGFloat = 60
    private let kDragThreshold2 : CGFloat = UIScreen.mainScreen().bounds.width - 60
    private let kIconInitialPosX : CGFloat = 10
    
    private let kArchiveIcon = "archive_icon"
    private let kDeleteIcon = "delete_icon"
    private let kScheduleIcon = "later_icon"
    private let kListIcon = "list_icon"
    
    private let cancelColor = UIColor(red: 227/255.0, green: 227/255.0, blue: 227/255.0, alpha: 1)
    private let scheduleColor = UIColor(red: 250/255.0, green: 211/255.0, blue: 98/255.0, alpha: 1)
    private let listColor = UIColor(red: 216/255.0, green: 166/255.0, blue: 117/255.0, alpha: 1)
    private let archiveColor = UIColor(red: 112/255.0, green: 217/255.0, blue:98/255.0, alpha: 1)
    private let deleteColor = UIColor(red: 235/255.0, green: 84/255.0, blue: 98/255.0, alpha: 1)
    private let mailColor = UIColor(red: 112/255.0, green: 197/255.0, blue: 88/255.0, alpha: 1)
    
    private enum SwipeAction {
        case CancelSchedule     // User has not swiped left far enough to take any action
        case Schedule       // User swiped left to schedule
        case List           // User swiped left to list
        case CancelArchive    // User has not swiped right far enough to take any action
        case Archive        // User swiped right to archive
        case Delete         // User swiped right to delete
    }
    
    private enum Direction {
        case Left
        case Right
    }
    
    @IBOutlet weak var messageView: UIImageView!
    @IBOutlet weak var messageBackground: UIView!
    @IBOutlet weak var feedView: UIImageView!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var rescheduleView: UIImageView!
    @IBOutlet weak var listView: UIImageView!
    @IBOutlet weak var menuView: UIImageView!

    @IBOutlet weak var scrollView: UIScrollView!
    
    var leftEdgePanGestureRecognizer : UIScreenEdgePanGestureRecognizer?
    var menuIsDisplayed = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resizeScrollViewForChildren(scrollView)
        menuView.frame.origin.x = -menuView.frame.width
        
        leftEdgePanGestureRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: Selector("onPanFromLeftEdgeOfScreen"))
        leftEdgePanGestureRecognizer!.edges = UIRectEdge.Left
        view.addGestureRecognizer(leftEdgePanGestureRecognizer!)
    }

    // Presentation logic for message ---------------
    
    // Returns which action the user indends to take based how far they swiped
    // swipeDistance < 0 for Left & > 0 for Right
    private func getActionFromSwipe(swipeDistance: CGFloat) -> SwipeAction {
        if (swipeDistance < 0) { // Swipe left
            if (swipeDistance > -kDragThreshold1) { // Gray Schedule
                return .CancelSchedule
            } else if (swipeDistance > -kDragThreshold2) { // Yellow Schedule
                return .Schedule
            } else { // Brown List
                return .List
            }
        } else { // Swipe right
            if (swipeDistance < kDragThreshold1) { // Gray archive
                return .CancelArchive
            } else if (swipeDistance < kDragThreshold2) { // Green archive
                return .Archive
            } else { // Red Delete
                return .Delete
            }
        }
    }
    
    private func getColorForAction(action: SwipeAction) -> UIColor {
        switch (action) {
        case .Archive:
            return archiveColor
        case .Delete:
            return deleteColor
        case .Schedule:
            return scheduleColor
        case .List:
            return listColor
        default: // CancelSchedule, CancelArchive
            return cancelColor
        }
    }
    
    private func getIconFromAction(action: SwipeAction) -> UIImage {
        switch (action) {
        case .Delete:
            return UIImage(named: kDeleteIcon)
        case .Schedule, .CancelSchedule:
            return UIImage(named: kScheduleIcon)
        case .List:
            return UIImage(named: kListIcon)
        default: // CancelArchive, Archive
            return UIImage(named: kArchiveIcon)
        }
    }
    
    private func getIconPosFromOffset(offsetX: CGFloat) -> CGFloat {
        if (offsetX < 0) { // Swipe left
            var screenWidth = UIScreen.mainScreen().bounds.width
            return min(screenWidth - kIconInitialPosX - icon.frame.width, screenWidth + offsetX + kIconInitialPosX)
        } else { // Swipe right
            return max(kIconInitialPosX, offsetX - kIconInitialPosX - icon.frame.width)
        }
    }
    
    @IBAction func onMessagePan(panGestureRecognizer: UIPanGestureRecognizer) {
        var translation = panGestureRecognizer.translationInView(messageView)
        var action = getActionFromSwipe(translation.x)
        
        if (panGestureRecognizer.state == UIGestureRecognizerState.Ended) {
            icon.hidden = true
            if (action == .CancelArchive || action == .CancelSchedule) {
                cancelRow()
            } else {
                removeRow(translation.x > 0 ? .Right : .Left, completion: { () -> Void in
                    self.showScreenForAction(action)
                })
            }
        } else {
            messageBackground.backgroundColor = getColorForAction(action)
            icon.hidden = false
            icon.image = getIconFromAction(action)
            icon.frame.origin.x = getIconPosFromOffset(translation.x)
            messageView.frame.origin.x = translation.x
        }
    }
    
    private func showScreenForAction(action: SwipeAction) {
        switch(action) {
        case .Schedule:
            showRescheduleView()
            break
        case .List:
            showListView()
            break
        default:
            return
        }
    }
    
    func cancelRow() {
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.messageView.frame.origin.x = 0
        })
    }
    
    private func removeRow(direction: Direction, completion: (() -> Void)?) {
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            switch (direction) {
            case .Right:
                    self.messageView.frame.origin.x = UIScreen.mainScreen().bounds.width
                break
            default: // Left
                self.messageView.frame.origin.x = -self.messageView.frame.width
            }
            }, completion: { (animate: Bool) -> Void in
                UIView.animateWithDuration(0.5, animations: { () -> Void in
                    self.feedView.frame.origin.y -= self.messageView.frame.height
                    }, completion: { (animate: Bool) -> Void in
                        self.messageView.frame.origin.x = 0
                        self.feedView.frame.origin.y += self.messageView.frame.height
                        if (completion != nil) {
                            completion!()
                        }
                })
        })
    }
    
    // Logic to show & hide reschedule or list screen --------------
    
    private func showRescheduleView() {
        self.rescheduleView.hidden = false
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.rescheduleView.alpha = 1
        })
    }
    
    private func showListView() {
        self.listView.hidden = false
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.listView.alpha = 1
        })
    }
    
    @IBAction func tapToDismissView(sender: UITapGestureRecognizer) {
        if (sender.view != nil) {
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                sender.view!.alpha = 0
                }) { (animate: Bool) -> Void in
                    sender.view!.hidden = false
            }
        }
    }
    
    func onPanFromLeftEdgeOfScreen() {
        if (!menuIsDisplayed) {
            var translation = leftEdgePanGestureRecognizer!.translationInView(messageView)
            menuView.frame.origin.x = translation.x - menuView.frame.width
            
            if (leftEdgePanGestureRecognizer!.state == UIGestureRecognizerState.Ended) {
                if (translation.x > kDragThreshold1) {
                    displayMenu()
                } else {
                    dismissMenu()
                }
            }
        }
    }
    
    // Logic to show & hide menu ----------------------------------
    
    @IBAction func onMenuSwipeLeft(sender: AnyObject) {
        dismissMenu()
    }
    
    func displayMenu() {
        println("show")
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.menuView.frame.origin.x = 0
        })
        menuIsDisplayed = true
    }
    
    func dismissMenu() {
        println("dmismiss")
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.menuView.frame.origin.x = -self.menuView.frame.width
        })
        menuIsDisplayed = false
    }
}
