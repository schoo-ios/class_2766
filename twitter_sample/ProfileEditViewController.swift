//
//  ProfileEditViewController.swift
//  twitter_sample
//
//  Created by Hiromasa Nagamine on 9/1/15.
//  Copyright (c) 2015 Hiromasa Nagamine. All rights reserved.
//

import UIKit
import Accounts
import Social

class ProfileEditViewController: UIViewController {

    @IBOutlet var userIcon: UIImageView!
    @IBOutlet var userNameLabel: UILabel!
    @IBOutlet var twitterIdLabel: UILabel!
    @IBOutlet var profileMessageView: UITextView!
    @IBOutlet var sendButton: UIButton!
    
    var twAccount = ACAccount()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        let URL = NSURL(string: "https://api.twitter.com/1.1/users/lookup.json?screen_name="+twAccount.username)
        
        let request = SLRequest(forServiceType: SLServiceTypeTwitter,
            requestMethod: .GET,
            URL: URL,
            parameters: nil)
        
        request.account = twAccount
        
        request.performRequestWithHandler { (data, response, error:NSError?) -> Void in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            
            if error != nil {
                println("Fetching Error: \(error)")
                return;
            }
            
            var tweetResponse: AnyObject? =  NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments, error: nil)
            
            if let tweetDict = tweetResponse as? Dictionary<String, AnyObject>{
                if let errors = tweetDict["errors"] as? Array<Dictionary<String,AnyObject>>{
                    var alert = UIAlertController(title: "Error", message: errors[0]["message"] as? String, preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .Default, handler:nil))
                    self.presentViewController(alert, animated: true, completion:nil)
                }
                
                return
            }
            
            var results = tweetResponse as! Array<Dictionary<String, AnyObject>>
            var myStatus = results[0]
            
            var userName = myStatus["name"] as? String
            var profileMessage = myStatus["description"]as? String
            var twitterID = "@"+self.twAccount.username
            var imageURL = NSURL(string: myStatus["profile_image_url"] as! String)
            var image = UIImage(data: NSData(contentsOfURL: imageURL!)!)
            
            dispatch_async(dispatch_get_main_queue(), {
                self.userNameLabel.text = userName
                self.profileMessageView.text = profileMessage
                self.twitterIdLabel.text = twitterID
                self.userIcon.image = image
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func tappedSendButton(sender: AnyObject) {
        
        let URL = NSURL(string: "https://api.twitter.com/1.1/account/update_profile.json")
        
        if count(profileMessageView.text) <= 0 {
            var alert = UIAlertController(title: "Error", message: "Please input text", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler:nil))
            self.presentViewController(alert, animated: true, completion:nil)
            
            return
        }
        
        var params = ["description": profileMessageView.text]
        
        // リクエストを生成
        let request = SLRequest(forServiceType: SLServiceTypeTwitter,
            requestMethod: .POST,
            URL: URL,
            parameters: params)
        
        // 取得したアカウントをセット
        request.account = twAccount
        
        // APIコールを実行
        request.performRequestWithHandler { (responseData, urlResponse, error) -> Void in
            
            if error != nil {
                println("error is \(error)")
            }
            else {
                // 結果の表示
                let result = NSJSONSerialization.JSONObjectWithData(responseData, options: .AllowFragments, error: nil) as! NSDictionary
                println("result is \(result)")
            }
        }
        self.navigationController?.popViewControllerAnimated(true)
    }
}
