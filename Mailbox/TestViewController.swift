//
//  TestViewController.swift
//  Mailbox
//
//  Created by Mel Ludowise on 10/19/14.
//  Copyright (c) 2014 Mel Ludowise. All rights reserved.
//

import UIKit

class TestViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        var leftEdgePanGestureRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: Selector("onEdgePan"))
        leftEdgePanGestureRecognizer.edges = UIRectEdge.Left
        view.addGestureRecognizer(leftEdgePanGestureRecognizer)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    func onEdgePan() {
        println("edge")
    }
}
