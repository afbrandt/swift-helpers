//
//  KeychainHelper.swift
//  swift-helpers
//
//  Created by Andrew Brandt on 2/4/15.
//  Copyright (c) 2015 dorystudios. All rights reserved.
//

import UIKit
import Security

let serviceIdentifier = "com.swift-helpers"

let kSecClassValue = kSecClass as NSString
let kSecAttrAccountValue = kSecAttrAccount as NSString
let kSecValueDataValue = kSecValueData as NSString
let kSecClassGenericPasswordValue = kSecClassGenericPassword as NSString
let kSecAttrServiceValue = kSecAttrService as NSString
let kSecMatchLimitValue = kSecMatchLimit as NSString
let kSecReturnDataValue = kSecReturnData as NSString
let kSecMatchLimitOneValue = kSecMatchLimitOne as NSString

class KeychainHelper: NSObject {
    
    class func setKeychainValue(value: String, forKey key: String) {
        var data = value.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
        
        var query: NSMutableDictionary = NSMutableDictionary(objects: [kSecClassGenericPasswordValue, serviceIdentifier, key, data], forKeys: [kSecClassValue, kSecAttrServiceValue, kSecAttrAccountValue, kSecValueDataValue])
                
        if key != "" {
            var status = SecItemAdd(query as CFDictionaryRef, nil) as OSStatus
            
            switch status {
            case errSecSuccess:
                println("keychain added without error")
                break;
            case errSecParam:
                #if DEBUG
                println("a parameter is missing from query")
                #endif
                break;
            case errSecAuthFailed, errSecInteractionNotAllowed:
                #if DEBUG
                println("some security error happened")
                #endif
                break;
            case errSecDuplicateItem:
                println("the item already exists")
                break;
            default:
                #if DEBUG
                println("something unexpected happened!")
                #endif
                break;
            }
        }
    }
    
    class func keychainValueForKey(key: String) -> String? {
        
        //build query for keychain lookup
        var query: NSMutableDictionary = NSMutableDictionary(objects: [kSecClassGenericPasswordValue, serviceIdentifier, key, kCFBooleanTrue, kSecMatchLimitOneValue], forKeys: [kSecClassValue, kSecAttrServiceValue, kSecAttrAccountValue, kSecReturnDataValue, kSecMatchLimitValue])
        
        var typeRef: Unmanaged<AnyObject>?
        
        //search keychain
        var keychainResponse: AnyObject?
        var result: String?
        
        var status = withUnsafeMutablePointer(&keychainResponse) { SecItemCopyMatching(query as CFDictionaryRef, UnsafeMutablePointer($0)) }
        
        switch status {
        case errSecSuccess:
            println("value found")
            if let data = keychainResponse as NSData? {
                if let string = NSString(data: data, encoding: NSUTF8StringEncoding) {
                    result = string as String
                }
            }
            break;
        case errSecItemNotFound:
            println("key %@ not found", key)
            break;
        case errSecAuthFailed, errSecInteractionNotAllowed:
            println("some security error happened")
            break;
        default:
            println("something unexpected happened!")
            break;
        }
        
        return result
    }
}