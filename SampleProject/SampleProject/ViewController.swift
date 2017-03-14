//
//  ViewController.swift
//  SampleProject
//
//  Created by Kothari, Sagar on 3/14/17.
//  Copyright © 2017 Sagar R. Kothari. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        SKUnlockDevice.performContextBasedDeviceLevelAuthentication { (result: DeviceLevelAuthenticationResult) in
            switch result {
            case .success:
                print("Successful Device Level Authentication.")
            case .noSecureUnlockAvailable:
                print("Secure unlock not available.")
            case .userCancelled:
                print("Use cancelled authentication.")
            case .unknownError:
                print("Unknown error thrown.")
            }
        }
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

