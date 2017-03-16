//
//  BusinessLayer.swift
//  Protect
//
//  Created by Honey Sachdeva on 20/07/2016.
//  Copyright (c) 2016 Honey Sachdeva. All rights reserved.
//

import Foundation

// Useing for social media

enum fGSLoginType:Int {
    case fGSLoginNormal
    case fGSLoginFacebook
    case fGSLoginTwitter
    case fGSLoginLinkedIn
}

class BusinessLayer: NSObject {
    
    var commMgr:CommunicationManager
    
    override init() {
        commMgr = CommunicationManager()
    }
   
    func socialSignUp(completionHandler:(success:Bool,errorMessage:String) -> Void)
    {
        
        //        if let tempUser = AppInstance.applicationInstance.user
//        {
//            var queryString = "?email=" + tempUser.email!
//            queryString = queryString + "&type=" + tempUser.socialmedia_type!
//            queryString = queryString + "&name=" + tempUser.name!
//            queryString = queryString + "&username=" + tempUser.name!
//            queryString = queryString + "&socialmedia_id=" + tempUser.socialmedia_id!
//            queryString = queryString + "&device_id=" + AppInstance.applicationInstance.device_id
//            queryString = queryString + "&device_type=1"
//            commMgr.GET(API.BASE_URL_STAGING+API.API_SOCIAL_REGISTER, queryString: queryString, sync: true, completionHandler: { (success, response) -> Void in
//                if(success == true) {
//                    Helper.printLog("enAPISignUp Response "+response)
//                    var tempUser : User?
//                    tempUser <-- response
//                    Helper.printLog(tempUser?.message)
//                    AppInstance.applicationInstance.user = tempUser!
//                    
//                    if tempUser!.message == nil {
//                        Helper.printLog("Data Saved")
//                        AppInstance.applicationInstance.userLoggedIn = true
//                        AppInstance.applicationInstance.user = tempUser!
//                        Helper.SaveUserObjectToFile(tempUser!)
//                        completionHandler(success: true, errorMessage: "")
//                        return
//                    }
//                    else {
//                        Helper.FGSLog("Data not Saved")
//                        if let msg = tempUser!.message {
//                            completionHandler(success: false, errorMessage: msg)
//                            return
//                        }
//                        else {
//                            completionHandler(success: false, errorMessage: "")
//                            return
//                        }
//                    }
//                }
//                    
//                else {
//                    Helper.FGSLog("enAPISignUp Response "+response)
//                    completionHandler(success: false, errorMessage: "")
//                    return
//                }
//            })
//        }
    }


    
}
