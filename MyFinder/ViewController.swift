//
//  ViewController.swift
//  My Finder
//
//  Created by lbp on 2019/3/19.
//  Copyright © 2019年 lbp. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    @IBOutlet weak var icon: NSImageCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        icon.image = NSWorkspace.shared.icon(forFile: "/System/Library/PreferencePanes/Extensions.prefPane")
        // Do any additional setup after loading the view.
    }
    @IBAction func didClickAboutButton(_ NSButton: Any) {
        NSWorkspace.shared.open(URL(string: "Http://www.github.com/sdlbp")!)
    }
    
    @IBAction func didClickFeedback(_ sender: NSButton) {
        let appName = Bundle.main.infoDictionary!["CFBundleName"] ?? "My Finder"
        let mailtoAddress = "mailto:sdlbp_feedback@163.com?Subject=\(appName) - Feedback".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        NSWorkspace.shared.open(URL(string: mailtoAddress!)!)
    }
    
    @IBAction func openPreferences(_ sender: Any) {
        NSWorkspace.shared.open(URL(fileURLWithPath: "/System/Library/PreferencePanes/Extensions.prefPane"))
    }
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

}

