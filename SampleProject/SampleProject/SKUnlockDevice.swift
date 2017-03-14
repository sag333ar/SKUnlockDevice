//
//  SKUnlockDevice.swift
//  SampleProject
//
//  Created by Kothari, Sagar on 3/14/17.
//  Copyright © 2017 Sagar R. Kothari. All rights reserved.
//

import Foundation
import LocalAuthentication

public enum DeviceLevelAuthenticationResult {
    case success
    case noSecureUnlockAvailable
    case userCancelled
    case unknownError
}

public struct SKUnlockDevice {
    public static func performContextBasedDeviceLevelAuthentication(_ keyChainItemIdentifier: String = "KeyChainEntryForDeviceLevelAuthentication", _ keyChainServiceName: String = "KeyChainServiceForDeviceLevelAuthentication", _ authPromptText: String = "Use touch ID to unlock this Application.", _ handler: @escaping ((DeviceLevelAuthenticationResult) -> Void)) {
        if #available(iOS 9.0, *) {
            let context: LAContext = LAContext()
            // Reference the error codes listed in the tutorial
            var error: NSError?
            // What the customer will see in the alert view
            let description = "Touch ID for 'M&S Bank Wallet'"
            if context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthentication, error: &error) {
                context.evaluatePolicy(LAPolicy.deviceOwnerAuthentication, localizedReason: description, reply: { (success, error) -> Void in
                    if success {
                        handler(DeviceLevelAuthenticationResult.success)
                    } else if let err = error {
                        switch (err as NSError).code {
                        case -5:
                            handler(DeviceLevelAuthenticationResult.noSecureUnlockAvailable)
                        case -2:
                            handler(DeviceLevelAuthenticationResult.userCancelled)
                        default:
                            handler(DeviceLevelAuthenticationResult.unknownError)
                        }
                    }
                })
            }
            if let err = error {
                switch (err as NSError).code {
                case -5:
                    handler(DeviceLevelAuthenticationResult.noSecureUnlockAvailable)
                case -2:
                    handler(DeviceLevelAuthenticationResult.userCancelled)
                default:
                    handler(DeviceLevelAuthenticationResult.unknownError)
                }
            }
        } else {
            self.performKeychainbasedDeviceLevelAuthentication(keyChainItemIdentifier, keyChainServiceName, authPromptText, handler)
        }
    }
    
    public static func performKeychainbasedDeviceLevelAuthentication(_ keyChainItemIdentifier: String, _ keyChainServiceName: String, _ authPromptText: String, _ handler: @escaping ((DeviceLevelAuthenticationResult) -> Void)) {
        // Step 1. Some data which will be used for storing with the help of key-chain. We won't store. This is just for validation.
        let data = ("The text to store as data." as NSString).data(using: String.Encoding.utf8.rawValue, allowLossyConversion: true)
        
        // Step 2. A key-chain entry attributes
        let attributes = NSMutableDictionary()
        attributes[kSecClass] = kSecClassGenericPassword
        attributes[kSecAttrAccount] = keyChainItemIdentifier
        attributes[kSecAttrService] = keyChainServiceName
        attributes[kSecValueData] = data
        attributes[kSecUseNoAuthenticationUI] = NSNumber(value: true)
        
        // Step 3. An error variable for next statement.
        let accessControlError:UnsafeMutablePointer<Unmanaged<CFError>?>? = nil
        
        // Step 4. Another key-chain attribute = Reference of Secure Access Control
        let accessControlRef = SecAccessControlCreateWithFlags(kCFAllocatorDefault, kSecAttrAccessibleWhenUnlockedThisDeviceOnly, SecAccessControlCreateFlags.userPresence, accessControlError)
        
        // Step 5. If we couldn't create an entry for access control, throw error & return
        if accessControlError != nil && accessControlRef == nil {
            // throw error and return
            handler(DeviceLevelAuthenticationResult.noSecureUnlockAvailable)
            return
        }
        
        // Step 6. Set AccessControl to key-chain-attributes.
        attributes[kSecAttrAccessControl] = accessControlRef
        
        // Step 7. A dictionary for query item
        let query = NSMutableDictionary()
        query[kSecClass] = kSecClassGenericPassword
        query[kSecAttrAccount] = keyChainItemIdentifier
        query[kSecAttrService] = keyChainServiceName
        query[kSecUseOperationPrompt] = authPromptText
        
        // Step 8. Add key-chain-entry to Secure Items (to perform DLA - part.1)
        SecItemAdd(attributes, nil)
        
        // Step 9. Query to device (to perform DLA - part.2)
        let result = SecItemCopyMatching(query, nil)
        
        // Step 10. If User successfully authenticated or not.
        if result == noErr {
            handler(DeviceLevelAuthenticationResult.success)
        } else {
            switch result {
            case -25293:
                handler(DeviceLevelAuthenticationResult.noSecureUnlockAvailable)
            case -128:
                handler(DeviceLevelAuthenticationResult.userCancelled)
            default:
                handler(DeviceLevelAuthenticationResult.unknownError)
            }
        }
    }
}
