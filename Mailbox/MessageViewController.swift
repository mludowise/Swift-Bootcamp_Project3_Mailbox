//
//  MessageViewController.swift
//  Mailbox
//
//  Created by Mel Ludowise on 10/18/14.
//  Copyright (c) 2014 Mel Ludowise. All rights reserved.
//

import UIKit

class MessageViewController: UIViewController {
    
    private let kDragThreshold1 : CGFloat = 0.25
    private let kDragThreshold2 : CGFloat = 0.75
    
    @IBOutlet weak var messageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        println("init")
    }

    @IBAction func onMessagePan(panGestureRecognizer: UIPanGestureRecognizer) {
//        var point = panGestureRecognizer.locationInView(view)
        var velocity = panGestureRecognizer.velocityInView(view)
        var translation = panGestureRecognizer.translationInView(messageView)
        println(translation)
        
        var screenWidth = UIScreen.mainScreen().bounds.width
        
        if (translation.x < 0) { // Swipe left
            if (translation.x > -screenWidth * kDragThreshold1) { // Gray Schedule
                
            } else { // Yellow Schedule
                
            }
        } else { // Swipe right
            if (translation.x < screenWidth * kDragThreshold1) { // Gray archive
                
            } else if (translation.x < screenWidth * kDragThreshold2) { // Green archive
                
            } else { // Red Delete
                
            }
        }
    }
}
