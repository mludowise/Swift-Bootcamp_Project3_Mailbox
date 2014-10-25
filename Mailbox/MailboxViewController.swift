//
//  MailboxViewController.swift
//  Mailbox
//
//  Created by Mel Ludowise on 10/18/14.
//  Copyright (c) 2014 Mel Ludowise. All rights reserved.
//

import UIKit

class MailboxViewController: UIViewController, UIActionSheetDelegate, UITextFieldDelegate, UIAlertViewDelegate {
    
    private let kDragThreshold1 : CGFloat = 60
    private let kDragThreshold2 : CGFloat = UIScreen.mainScreen().bounds.width - 60
    private let kIconInitialPosX : CGFloat = 10
    
    private let kInboxIcon = "mail_nav_icon"
    private let kArchiveIcon = "archive_icon"
    private let kDeleteIcon = "delete_icon"
    private let kLaterIcon = "later_icon"
    private let kListIcon = "list_icon"
    
    private let cancelColor = UIColor(red: 227/255.0, green: 227/255.0, blue: 227/255.0, alpha: 1)
    private let laterColor = UIColor(red: 250/255.0, green: 211/255.0, blue: 98/255.0, alpha: 1)
    private let listColor = UIColor(red: 216/255.0, green: 166/255.0, blue: 117/255.0, alpha: 1)
    private let archiveColor = UIColor(red: 112/255.0, green: 217/255.0, blue:98/255.0, alpha: 1)
    private let deleteColor = UIColor(red: 235/255.0, green: 84/255.0, blue: 98/255.0, alpha: 1)
    private let inboxColor = UIColor(red: 112/255.0, green: 197/255.0, blue: 224/255.0, alpha: 1)
    
    private let kComposeMessageOrigin = CGPoint(x: 0, y: 85)
    
    private enum SwipeAction {
        case CancelLeft     // User has not swiped left far enough to take any action
        case CancelRight    // User has not swiped right far enough to take any action
        case Later          // User swiped left to schedule for later
        case List           // User swiped left to list
        case Archive        // User swiped right to archive
        case Delete         // User swiped right to delete
        case Inbox          // User swiped left from archive view
    }
    
    private enum Direction {
        case Left
        case Right
    }
    
    // Feed View
    @IBOutlet weak var messageView: UIImageView!
    @IBOutlet weak var messageBackground: UIView!
    @IBOutlet weak var feedView: UIImageView!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var searchView: UIImageView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var composeButton: UIBarButtonItem!
    
    var messageRemoved = false
    
    // Compose Message
    @IBOutlet weak var composeView: UIView!
    @IBOutlet weak var composeMessageView: UIView!
    @IBOutlet weak var sendButton: UIBarButtonItem!
    @IBOutlet weak var toField: UITextField!
    @IBOutlet weak var subjectField: UITextField!
    @IBOutlet weak var messageField: UITextView!

    // Other Views
    @IBOutlet weak var rescheduleView: UIImageView!
    @IBOutlet weak var listView: UIImageView!
    @IBOutlet weak var menuView: UIImageView!
//    var leftEdgePanGestureRecognizer : UIScreenEdgePanGestureRecognizer?
    var menuIsDisplayed = false
    @IBOutlet weak var mainFeedView: UIView!
    
    // Filtering
    @IBOutlet weak var dummyFeedView: UIView!
    @IBOutlet weak var filterControl: UISegmentedControl!
    var prevFilterIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resizeScrollViewForChildren(scrollView)
        println(scrollView.contentSize)
        println(scrollView.frame.size)
//        menuView.frame.origin.x = -menuView.frame.width
        hideSearch()
        
        var edgePanGestureRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: "onPanFromLeftEdgeOfScreen:")
        edgePanGestureRecognizer.edges = UIRectEdge.Left
        mainFeedView.addGestureRecognizer(edgePanGestureRecognizer)
        
        edgePanGestureRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: "onPanFromRightEdgeOfScreen:")
        edgePanGestureRecognizer.edges = UIRectEdge.Right
        mainFeedView.addGestureRecognizer(edgePanGestureRecognizer)
        
        
        prevFilterIndex = filterControl.selectedSegmentIndex
        updateFilterColor()
        
        toField.delegate = self
        subjectField.delegate = self
    }
    
    private func hideSearch() {
        scrollView.contentOffset.y = searchView.frame.height + searchView.frame.origin.y
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    // Presentation logic for message ---------------
    
    // Returns which action the user indends to take based how far they swiped
    // swipeDistance < 0 for Left & > 0 for Right
    private func getActionFromSwipe(swipeDistance: CGFloat) -> SwipeAction {
        
        if (swipeDistance < 0) { // Swipe left
            if (swipeDistance > -kDragThreshold1) {
                return .CancelLeft
            } else if (swipeDistance > -kDragThreshold2) {
                switch (filterControl.selectedSegmentIndex) {
                case 0, 1: // Later & Inbox
                    return .Later
                default: // Archive
                    return .Inbox
                }
            } else { // Brown List
                switch (filterControl.selectedSegmentIndex) {
                case 0, 1: // Later & Inbox
                    return .List
                default: // Archive
                    return .Later
                }
            }
        } else { // Swipe right
            if (swipeDistance < kDragThreshold1) { // Gray archive
                return .CancelRight
            } else if (swipeDistance < kDragThreshold2) { // Green archive
                switch (filterControl.selectedSegmentIndex) {
                case 0: // Later
                    return .Inbox
                case 1: // Inbox
                    return .Archive
                default: // Archive
                    return .Delete
                }
            } else { // Red Delete
                switch (filterControl.selectedSegmentIndex) {
                case 0: // Later
                    return .Archive
                default: // Inbox & Archive
                    return .Delete
                }
            }
        }
    }
    
    private func getColorForAction(action: SwipeAction) -> UIColor {
        switch (action) {
        case .Inbox:
            return inboxColor
        case .Archive:
            return archiveColor
        case .Delete:
            return deleteColor
        case .Later:
            return laterColor
        case .List:
            return listColor
        default: // CancelLeft, CancelRight
            return cancelColor
        }
    }
    
    private func getIconFromAction(action: SwipeAction) -> UIImage {
        switch (action) {
        case .Inbox:
            return UIImage(named: kInboxIcon)!
        case .Archive:
            return UIImage(named: kArchiveIcon)!
        case .Delete:
            return UIImage(named: kDeleteIcon)!
        case .Later:
            return UIImage(named: kLaterIcon)!
        case .List:
            return UIImage(named: kListIcon)!
        case .CancelLeft:
            return getIconFromAction(getActionFromSwipe(-kDragThreshold1))
        default: // CancelRight
            return getIconFromAction(getActionFromSwipe(kDragThreshold1))
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
            if (action == .CancelRight || action == .CancelLeft) {
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
        case .Later:
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
        messageRemoved = true
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
                        if (completion != nil) {
                            completion!()
                        }
                })
        })
    }
    
    private func addRow() {
        messageRemoved = false
        self.messageView.frame.origin.x = 0
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.feedView.frame.origin.y += self.messageView.frame.height
        })
    }
    
    // Logic for undo ------------------------------------------
    
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent) {
        if (motion == UIEventSubtype.MotionShake) {
            if (messageRemoved) {
                var alertView = UIAlertView(title: "Undo last action?", message: "Are you sure you want to undo that?", delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "Undo")
                alertView.show()
            } else {
                var alertView = UIAlertView(title: "Nothing to undo.", message: "", delegate: nil, cancelButtonTitle: "OK")
                alertView.show()
            }
        }
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if (buttonIndex > 0) {
            addRow()
        }
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
    
    // Logic to show & hide menu ----------------------------------
    
    func onPanFromLeftEdgeOfScreen(sender: UIPanGestureRecognizer) {
        if (!menuIsDisplayed) {
            var translation = sender.translationInView(mainFeedView)
            var velocity = sender.velocityInView(mainFeedView)
            
            mainFeedView.frame.origin.x = translation.x
            
            if (sender.state == UIGestureRecognizerState.Ended) {
                if (velocity.x > 0) {
                    displayMenu()
                } else {
                    dismissMenu()
                }
            }
        }
    }
    
    func onPanFromRightEdgeOfScreen(sender: UIPanGestureRecognizer) {
        if (menuIsDisplayed) {
            var translation = sender.translationInView(mainFeedView)
            var velocity = sender.velocityInView(mainFeedView)
            
            mainFeedView.frame.origin.x = translation.x + mainFeedView.frame.width - 20
            
            if (sender.state == UIGestureRecognizerState.Ended) {
                if (velocity.x > 0) {
                    displayMenu()
                } else {
                    dismissMenu()
                }
            }
        }
    }
    
    @IBAction func onMainViewTap(sender: UITapGestureRecognizer) {
        if (menuIsDisplayed) {
            dismissMenu()
        }
    }
    
    @IBAction func onMenuSwipeLeft(sender: AnyObject) {
        dismissMenu()
    }
    
    @IBAction func onMenuButton(sender: AnyObject) {
        displayMenu()
    }
    
    func displayMenu() {
        UIView.animateWithDuration(0.5, animations: { () -> Void in
//            self.menuView.frame.origin.x = 0
            self.mainFeedView.frame.origin.x = UIScreen.mainScreen().bounds.width - 20
        })
        menuIsDisplayed = true
    }
    
    func dismissMenu() {
        UIView.animateWithDuration(0.5, animations: { () -> Void in
//            self.menuView.frame.origin.x = -self.menuView.frame.width
            self.mainFeedView.frame.origin.x = 0
        })
        menuIsDisplayed = false
    }
    
    // Logic for filter menu ----------------------------------
    
    @IBAction func onFilter(sender: UISegmentedControl) {
        animateFilter(prevFilterIndex < filterControl.selectedSegmentIndex ? .Left : .Right)
        prevFilterIndex = filterControl.selectedSegmentIndex
    }
    
    private func animateFilter(direction: Direction) {
        // Left
        self.dummyFeedView.hidden = false
        dummyFeedView.frame.origin.x = direction == .Left ?
            UIScreen.mainScreen().bounds.width :    // Left
            -dummyFeedView.frame.width              // Right
        
        
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.scrollView.frame.origin.x = direction == .Left ?
                -self.scrollView.frame.width :      // Left
                UIScreen.mainScreen().bounds.width  // Right
                
            self.dummyFeedView.frame.origin.x = 0
            self.updateFilterColor()
            }) { (animate: Bool) -> Void in
                self.hideSearch()
                self.scrollView.frame.origin.x = 0
                self.dummyFeedView.hidden = true
        }
    }
    
    private func updateFilterColor() {
        var color : UIColor!
        switch (filterControl.selectedSegmentIndex) {
        case 0: // Later
            color = laterColor
            break
        case 1: // Inbox
            color = inboxColor
            break
        default: // Archive
            color = archiveColor
        }
        menuButton.tintColor = color
        composeButton.tintColor = color
        filterControl.tintColor = color
    }
    
    // Compose Message Logic ----------------------------------
    
    private func showComposeMessage() {
        composeView.hidden = false
        composeMessageView.frame.origin.y = UIScreen.mainScreen().bounds.height
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            self.composeView.alpha = 1
            self.composeMessageView.frame.origin = self.kComposeMessageOrigin
            self.toField.becomeFirstResponder()
        })
    }
    
    private func hideComposeMessage() {
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            self.composeView.alpha = 0
            self.composeMessageView.frame.origin.y = UIScreen.mainScreen().bounds.height
            self.view.endEditing(true)
            }) { (animate: Bool) -> Void in
                
        }
    }
    func actionSheet(actionSheet: UIActionSheet, didDismissWithButtonIndex buttonIndex: Int) {
        if (buttonIndex != 1) { // Anything but cancel
            hideComposeMessage()
        }
    }

    private func cancelMessage() {
        var actionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: "Delete Draft", otherButtonTitles: "Keep Draft")
        actionSheet.showInView(view)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if (textField == toField) {
            subjectField.becomeFirstResponder()
        } else if (textField == subjectField) {
            messageField.becomeFirstResponder()
        }
        return true
    }
    
    @IBAction func onComposeButton(sender: AnyObject) {
        showComposeMessage()
    }
    
    @IBAction func toFieldChanged(sender: AnyObject) {
        sendButton.enabled = toField.text != ""
    }
    
    @IBAction func onSendButton(sender: AnyObject) {
        hideComposeMessage()
    }
    
    @IBAction func onCancelButton(sender: AnyObject) {
        cancelMessage()
    }
    
    @IBAction func onTapToCancelCompose(sender: AnyObject) {
        cancelMessage()
    }
}
