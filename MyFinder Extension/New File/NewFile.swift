//
//  NewFile.swift
//  My Finder Extension
//
//  Created by lbp on 2019/3/25.
//  Copyright © 2019年 lbp. All rights reserved.
//

import Cocoa

protocol NewFile {
    var templateType: [String] {get}
    var newFileMenus: [NSMenuItem] {get}
    func getFileType(menuItemTitle: String?) -> String
}

extension FinderSync: NewFile {
    struct MenuItemTitle {
        static let separator = "---"
        
        static let textFile = NSLocalizedString("Text File", comment: "")
        static let richFile = NSLocalizedString("Rich File", comment: "")
        
        static let keynoteFile = NSLocalizedString("Keynote File", comment: "")
        static let pagesFile = NSLocalizedString("Pages File", comment: "")
        static let numbersFile = NSLocalizedString("Numbers File", comment: "")
        
        static let wordFile = NSLocalizedString("Word File", comment: "")
        static let excelFile = NSLocalizedString("Excel File", comment: "")
        static let powerPointFile = NSLocalizedString("PowerPoint File", comment: "")
        
        static let markdownFile = NSLocalizedString("Markdown File", comment: "")
        static let HTMLFile = NSLocalizedString("HTML File", comment: "")
        static let CSSFile = NSLocalizedString("CSS File", comment: "")
        static let JavaScriptFile = NSLocalizedString("JavaScipt File", comment: "")
        static let pythonFile = NSLocalizedString("Python File", comment: "")
        static let other = NSLocalizedString("Others", comment: "")
    }
    
    func getFileType(menuItemTitle: String?) -> String {
        guard let title = menuItemTitle else {
            return ""
        }
        switch title {
        case MenuItemTitle.textFile:
            return "text"
        case MenuItemTitle.richFile:
            return "rtf"
        case MenuItemTitle.keynoteFile:
            return "key"
        case MenuItemTitle.pagesFile:
            return "pages"
        case MenuItemTitle.numbersFile:
            return "numbers"
        case MenuItemTitle.wordFile:
            return "docx"
        case MenuItemTitle.excelFile:
            return "xlsx"
        case MenuItemTitle.powerPointFile:
            return "pptx"
        case MenuItemTitle.markdownFile:
            return "md"
        case MenuItemTitle.HTMLFile:
            return "html"
        case MenuItemTitle.CSSFile:
            return "css"
        case MenuItemTitle.JavaScriptFile:
            return "js"
        case MenuItemTitle.pythonFile:
            return "py"
        default:
            return ""
        }
    }
    
    var templateType: [String] {
        return ["rtf", "html", "pages", "key", "numbers", "py", "rb", "sh", "xlsx"]
    }
    
    var newFileMenus: [NSMenuItem] {
        let appList = try! FileManager.default.contentsOfDirectory(atPath: "/Applications/")
        let appListStr = appList.joined().lowercased()
        
        var fileTypes = [MenuItemTitle.textFile,
                         MenuItemTitle.richFile,
                         MenuItemTitle.separator]
        
        var macOffer = [String]()
        if appListStr.contains("keynote") {
            macOffer.append(MenuItemTitle.keynoteFile)
        }
        if appListStr.contains("pages") {
            macOffer.append(MenuItemTitle.pagesFile)
        }
        if appListStr.contains("numbers") {
            macOffer.append(MenuItemTitle.numbersFile)
        }
        if macOffer.count > 0 {
            fileTypes += macOffer
            fileTypes.append(MenuItemTitle.separator)
        }
        
        var windowsOffer = [String]()
        if appListStr.contains("word") {
            windowsOffer.append(MenuItemTitle.wordFile)
        }
        if appListStr.contains("excel") {
            windowsOffer.append(MenuItemTitle.excelFile)
        }
        if appListStr.contains("powerpoint") {
            windowsOffer.append(MenuItemTitle.powerPointFile)
        }
        if windowsOffer.count > 0 {
            fileTypes += windowsOffer
            fileTypes.append(MenuItemTitle.separator)
        }
        
        fileTypes += [MenuItemTitle.markdownFile, MenuItemTitle.HTMLFile, MenuItemTitle.CSSFile, MenuItemTitle.JavaScriptFile, MenuItemTitle.pythonFile, MenuItemTitle.separator, MenuItemTitle.other]
        
        var result = [NSMenuItem]()
        fileTypes.forEach({ (title) in
            let item = creatMenuItem(for: .custom(title: title, selector: #selector(newFile(_:))))
            result.append(item)
        })
        return result
    }
}
