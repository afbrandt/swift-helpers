//
//  DefaultsHelper.swift
//  swift-helpers
//
//  Created by Andrew Brandt on 2/4/15.
//  Copyright (c) 2015 dorystudios. All rights reserved.
//

class DefaultsHelper {
    
    var name: String = NSUserDefaults.standardUserDefaults().stringForKey("myName") ?? "User" {
        didSet {
            NSUserDefaults.standardUserDefaults().setObject(name, forKey:"myName")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }

    var highScore: Int = NSUserDefaults.standardUserDefaults().stringForKey("myHighScore") ?? 0 {
        didSet {
            NSUserDefaults.standardUserDefaults().setInteger(highScore, forKey:"myHighScore")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
}