//
//  Common.swift
//  My Finder Extension
//
//  Created by lbp on 2019/3/20.
//  Copyright © 2019年 lbp. All rights reserved.
//

import Cocoa

struct Common {
    static func alert(_ message: String) {
        let alert: NSAlert
        alert = NSAlert()
        alert.messageText = "My Finder"
        alert.alertStyle = .warning
        alert.informativeText = message
        alert.addButton(withTitle: "OK")
        DispatchQueue.main.async {
            alert.runModal()
        }
    }
}
