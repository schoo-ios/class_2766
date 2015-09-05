//
//  ViewController.swift
//  twitter_sample
//
//  Created by NAGAMINE HIROMASA on 2015/08/16.
//  Copyright (c) 2015年 Hiromasa Nagamine. All rights reserved.
//

import UIKit
import Accounts

class ViewController: UIViewController {
    
    var accountStore = ACAccountStore()   // 追加
    var twAccount = ACAccount()          // 追加
    var accounts = [ACAccount]()
    
    @IBOutlet var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func tappedLoginButton(sender: AnyObject) {
        getTwitterAccountsFromDevice()
    }
    
    /* iPhoneに設定したTwitterアカウントの情報を取得する */
    func getTwitterAccountsFromDevice(){
        let accountType = accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
        accountStore.requestAccessToAccountsWithType(accountType, options: nil) { (granted:Bool, aError:NSError?) -> Void in
            
            // アカウント取得に失敗したとき
            if let error = aError {
                println("Error! - \(error)")
                return;
            }
            
            // アカウント情報へのアクセス権限がない時
            if !granted {
                println("Cannot access to account data")
                return;
            }
            
            // アカウント情報の取得に成功
            self.accounts = self.accountStore.accountsWithAccountType(accountType) as! [ACAccount]
            self.showAndSelectTwitterAccountWithSelectionSheets()
        }
    }
    
    /* iPhoneに設定したTwitterアカウントの選択画面を表示する */
    func showAndSelectTwitterAccountWithSelectionSheets() {
        
        // アクションシートの設定
        var alertController = UIAlertController(title: "Select Account", message: "Please select twitter account", preferredStyle: .ActionSheet)
        
        for account in accounts {
            
            alertController.addAction(UIAlertAction(title: account.username, style: .Default, handler: { (action) -> Void in
                // 選択したアカウントをtwAccountに保存
                self.twAccount = account
                self.performSegueWithIdentifier("segueTimelineViewController", sender: nil)
            }))
            
        }
        
        // キャンセルボタンは何もせずにアクションシートを閉じる
        let CanceledAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertController.addAction(CanceledAction)
        
        // アクションシート表示
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    // TimelineViewControllerを表示する際に選択したアカウントを渡す
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueTimelineViewController" {
            var vc = segue.destinationViewController as! TimelineViewController
            vc.twAccount = self.twAccount
        }
    }
    
}

