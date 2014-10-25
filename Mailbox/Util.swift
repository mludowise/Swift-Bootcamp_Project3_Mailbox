//
//  Util.swift
//  Mailbox
//
//  Created by Mel Ludowise on 10/18/14.
//  Copyright (c) 2014 Mel Ludowise. All rights reserved.
//

import Foundation
import UIKit

func resizeScrollViewForChildren(scrollView: UIScrollView) {
    var height = 0 as CGFloat
    for view in scrollView.subviews {
        height += view.frame.height
    }
    scrollView.contentSize.height = height
    scrollView.contentSize.width = scrollView.frame.width
}