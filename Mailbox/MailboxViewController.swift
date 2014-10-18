//
//  MailboxViewController.swift
//  Mailbox
//
//  Created by Mel Ludowise on 10/18/14.
//  Copyright (c) 2014 Mel Ludowise. All rights reserved.
//

import UIKit

class MailboxViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resizeScrollViewForChildren(scrollView)
    }
}
