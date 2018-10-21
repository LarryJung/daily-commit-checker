//
//  AppDelegate.swift
//  daily-commit-checker
//
//  Created by chaegyun jung on 2018. 10. 21..
//  Copyright © 2018년 chaegyun jung. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem = NSStatusBar.system.statusItem(withLength: -1)
    @IBOutlet var mainMenu: NSMenu!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusItem.title = "오늘 커밋 며칠째?"
        if let button = statusItem.button {
            button.action = #selector(getNumberToShow)
        }
    }
    
    @objc func getNumberToShow() {
        let url : String = "https://github.com/larryjung"
        var n = 0
        dataTask(url: url) { results in
            let commits = results.toCommitsInfo()
            for (i, c) in commits.reversed().enumerated() {
                if c != "0" {
                    n = n + 1
                } else {
                    if (i == 0) {
                        continue
                    } else {
                        self.updateDisplay(n: n)
                        break
                    }
                }
            }
        }
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func updateDisplay(n: Int) {
        statusItem.title = "오늘까지 커밋 \(n)일째!"
    }
    
    func dataTask(url: String, completeHandler: @escaping (String) -> ()) {
        let url = URL(string: url)!
        let urlSession = URLSession.shared
        let getRequest = URLRequest(url: url)
        
        let task = urlSession.dataTask(with: getRequest as URLRequest, completionHandler: { data, response, error in
            
            guard error == nil else {
                return
            }
            
            guard let data = data else {
                return
            }
            completeHandler(String(data: data, encoding: String.Encoding.utf8) as String!)
        })
        
        task.resume()
        
    }
}

extension String
{
    func toCommitsInfo() -> [String]
    {
        if let regex = try? NSRegularExpression(pattern: "data-count=\"[0-9]\"+", options: .caseInsensitive)
        {
            let string = self as NSString
            
            return regex.matches(in: self, options: [], range: NSRange(location: 0, length: string.length)).map {
                string.substring(with: $0.range)
                    .replacingOccurrences(of: "data-count=", with: "")
                    .replacingOccurrences(of: "\"", with: "")
            }
        }
        return []
    }
}

