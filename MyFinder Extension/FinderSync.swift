//
//  FinderSync.swift
//  My Finder Extension
//
//  Created by lbp on 2019/3/19.
//  Copyright © 2019年 lbp. All rights reserved.
//

import Cocoa
import FinderSync

class FinderSync: FIFinderSync {
    var myFolderURL = URL(fileURLWithPath: "/")

    override init() {
        super.init()
        
        // Set up the directory we are syncing.
        FIFinderSyncController.default().directoryURLs = [self.myFolderURL]
    }
    
    // MARK: - Menu and toolbar item support
    
    override var toolbarItemName: String {
        return "My Finder"
    }
    
    override var toolbarItemToolTip: String {
        return "My Finder: Click the toolbar item for a menu."
    }
    
    override var toolbarItemImage: NSImage {
        return NSImage(named: "Icon_32x32")!
    }
    
    override func menu(for menuKind: FIMenuKind) -> NSMenu {
        let menu = NSMenu()
        let newFile = creatMenuItem(for: .newFile)
        let copyPath = creatMenuItem(for: .copyPath)
        let openTerminal = creatMenuItem(for: .openTerminal)
        let openTerminalTab = creatMenuItem(for: .openTerminalTab)
        
        let newFileSub = NSMenu()
        self.newFileMenus.forEach { (menuItem) in
            newFileSub.addItem(menuItem)
        }
        newFile.submenu = newFileSub
        /**
         这种菜单方式感觉不够高效
         //        switch menuKind {
         //        case .toolbarItemMenu:
         //            menu.addItem(newFile)
         //            menu.addItem(copyPath)
         //            menu.addItem(openTerminal)
         //            menu.addItem(openTerminalTab)
         //        default:
         //            let menuSup = NSMenuItem(title: "My Finder", action: nil, keyEquivalent: "")
         //            let subMenu = NSMenu()
         //
         //            subMenu.addItem(newFile)
         //            subMenu.addItem(copyPath)
         //            subMenu.addItem(openTerminal)
         //            subMenu.addItem(openTerminalTab)
         //
         //            menu.addItem(menuSup);
         //            menuSup.submenu = subMenu;
         //        }
         */
        menu.addItem(newFile)
        menu.addItem(copyPath)
        menu.addItem(openTerminal)
        menu.addItem(openTerminalTab)
        return menu
    }
    
    enum MenuItemType {
        case newFile
        case copyPath
        case openTerminalTab
        case openTerminal
        case custom(title: String,selector: Selector)
    }
    
    func creatMenuItem(for menuType: MenuItemType) -> NSMenuItem {
        switch menuType {
        case .newFile:
            return NSMenuItem(title: NSLocalizedString("New File", comment: ""), action: nil, keyEquivalent: "")
        case .copyPath:
            return NSMenuItem(title: NSLocalizedString("Copy Path", comment: ""), action: #selector(copyPath(_:)), keyEquivalent: "")
        case .openTerminalTab:
            return NSMenuItem(title: NSLocalizedString("Open Terminal On Tab", comment: ""), action: #selector(openTerminalTab(_:)), keyEquivalent: "")
        case .openTerminal:
            return NSMenuItem(title: NSLocalizedString("Open Terminal", comment: ""), action: #selector(openTerminal(_:)), keyEquivalent: "")
        case .custom(let title, let selector):
            if title == MenuItemTitle.separator {
//                return NSMenuItem.separator() // TODO 为何是空白分割??
                let s = NSMenuItem(title: "----------", action: nil, keyEquivalent: "")
                s.isEnabled = false
                return s
            }else {
                return NSMenuItem(title: title, action: selector, keyEquivalent: "")
            }
        }
    }
}

/// menu item action
extension FinderSync {
    @IBAction func newFile(_ sender: NSMenuItem?) {
        print("new file")
        let targetURL = FIFinderSyncController.default().targetedURL()

        DispatchQueue.main.async {
            let savePanel = NSSavePanel()
            savePanel.level = NSWindow.Level.modalPanel
            savePanel.title = NSLocalizedString("New File", comment: "")
            savePanel.allowedFileTypes = [self.getFileType(menuItemTitle: sender?.title)]
            savePanel.directoryURL = targetURL
            savePanel.allowsOtherFileTypes = true
            savePanel.isExtensionHidden = false
            savePanel.canCreateDirectories = true
            savePanel.begin(completionHandler: { (result) in
                if result == NSApplication.ModalResponse.OK {
                    guard let path = savePanel.url else {
                        return
                    }
                    let fileManager = FileManager.default
                    let fileType = path.lastPathComponent.components(separatedBy: ".").last
                    if fileType != nil && self.templateType.contains(fileType!) {
                        do {
                            guard let templatePath = Bundle(for: FinderSync.self).path(forResource: "Untitled", ofType: fileType) else {
                                return
                            }
                            try fileManager.copyItem(at: URL(fileURLWithPath: templatePath), to: path)
                        }catch {
                            print("error \(error)")
                            Common.alert(NSLocalizedString("alert.copy_template_error", comment: "拷贝模板错误alert"))
                        }
                    }else {
                        if !fileManager.createFile(atPath: path.path, contents: nil, attributes: nil) {
                            Common.alert(NSLocalizedString("alert.new_file_error", comment: "新建文件错误alert"))
                        }
                    }
                }
            });
            // TOOD 获取焦点
//            savePanel.becomeFirstResponder()
        }
    }
    
    /// 将要打开的路径
    private var urlsToOpen: [URL] {
        get {
            // get the current directory and selected items, bail out if either is nil (which shouldn’t be
            // possible, but still)
            guard let target = FIFinderSyncController.default().targetedURL() else {
                NSLog("target is nil – attempting to open from an unknown path?")
                return []
            }
            
            guard let items = FIFinderSyncController.default().selectedItemURLs() else {
                NSLog("items is nil – attempting to open from an unknown path?")
                return []
            }
            
            // if opening selection is enabled and there are selected items, use them. otherwise, use the
            // current directory
            if items.count > 0 {
                return items
            } else {
                return [ target ]
            }
        }
    }
    
    @IBAction func openTerminal(_ sender: NSMenuItem?) {
        let urls = urlsToOpen
        
        // hop over to the main queue
        DispatchQueue.main.async {
            // launch them!
            let service = "New Terminal at Folder"
            _ = ServiceRunner.run(service: service, withFileURLs: urls)
        }
    }
    
    @IBAction func openTerminalTab(_ sender: NSMenuItem?) {
        let urls = urlsToOpen
        
        // hop over to the main queue
        DispatchQueue.main.async {
            // launch them!
            let service = "New Terminal Tab at Folder"
            _ = ServiceRunner.run(service: service, withFileURLs: urls)
        }
        
    }
    
    @IBAction func copyPath(_ sender: NSMenuItem?) {
//        print("copy path")
        let items = FIFinderSyncController.default().selectedItemURLs()
        
        guard let paths = items else {
            return
        }
        var str: String = ""
        for obj in paths {
            str.append(obj.path)
            str.append("\n")
        }
        
        // copy to clipboard https://github.com/zhaorui/PbDemo
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        let success = pasteboard.setString(str, forType: .string)
        if (!success) {
            Common.alert(NSLocalizedString("alert.copy_pasteboard_error", comment: "拷贝复制版错误提示"))
        }
    }
}

class ServiceRunner {
    fileprivate static var pasteboard: NSPasteboard = {
        let bundleIdentifier = Bundle.main.bundleIdentifier!
        return NSPasteboard(name: NSPasteboard.Name(rawValue: "\(bundleIdentifier).pasteboard"))
    }()
    
    class func run(service: String, withFileURLs fileURLs: [URL]) -> Bool {
        // completely undocumented as far as i can tell, but NSPerformService() must be called from the
        // main thread. otherwise it’ll crash when displaying error messages as an NSAlert() because it
        // doesn’t jump to the main thread before calling runModal!
        // TODO: radar
        if !Thread.isMainThread {
            fatalError("ServiceRunner.run() called from non-main thread!")
        }
        
        var pasteboardItems: [NSPasteboardItem] = []
        
        // loop over each item and create an NSPasteboardItem for it. this allows us to send all items
        // to the service in one go
        for url in fileURLs {
            let item = NSPasteboardItem()
            item.setString(url.path, forType: .compatString)
            
            pasteboardItems.append(item)
        }
        
        pasteboard.declareTypes([ .compatString ], owner: nil)
        pasteboard.writeObjects(pasteboardItems)
        
        if !NSPerformService(service, self.pasteboard) {
            NSLog("service execution failed, and we don’t know why!!")
            return false
        }
        
        return true
    }
    
}
