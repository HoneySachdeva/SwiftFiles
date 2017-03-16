//
//  CommunicationManager.swift


import UIKit

class CommunicationManager: NSObject
{
    enum AccessTokenConcept {
        case ResultSuccess // Got success for the first time
        case AccessTokenExpire // Request for new access token and hit the API again
        case RefreshTokenExpire // In case when refresh token is also expire
    }
    
    func webServiceWithDicParam(showLoader: Bool,methodType: NSString, methodName: NSString, inputDict: NSDictionary, completion: (result: [String:AnyObject]) -> Void, failure:(failurMSG: NSString)->()){
        
       
        if (Internet.isAvailable() == false) {
            //END TASK _ FAILURE
            endTaskWithFailureInternet(showLoader, failure: failure)
            return
        }
        
        do {
            
            print(inputDict)
            let data: NSData = try NSJSONSerialization.dataWithJSONObject(inputDict, options: [])
            if showLoader {
                Spiner.activate()
            }
            
            //create request
            let tmpString: String = "\(API.BASE_URL)\(methodName)"
            let  urlString :String = tmpString.stringByAddingPercentEncodingWithAllowedCharacters( NSCharacterSet.URLQueryAllowedCharacterSet())!
            
            let urlRequest = jsonReqWithAccessToken(urlString, requestType: methodType as String, data: data)
            
            //CREATE A TASK WITH REQUEST
            createTaskWithRequest(urlRequest, showLoader: showLoader, completion: completion, failure: failure)
            
        }catch
        {
            //END TASK _ FAILURE
            endTaskWithFailure(showLoader, failure: failure)
        }
    }
    
    func webServiceWithDicParamForGoogleDirections(showLoader: Bool,methodType: NSString, methodName: NSString, inputDict: NSDictionary, completion: (result: [String:AnyObject]) -> Void, failure:(failurMSG: NSString)->()){
        
        
        if (Internet.isAvailable() == false) {
            //END TASK _ FAILURE
            endTaskWithFailureInternet(showLoader, failure: failure)
            return
        }
        
        do {
            
            let data: NSData = try NSJSONSerialization.dataWithJSONObject(inputDict, options: [])
            if showLoader {
                Spiner.activate()
            }
            
            //create request
            let tmpString: String = "https://maps.googleapis.com/maps/api/directions/json?\(methodName)"
            let  urlString :String = tmpString.stringByAddingPercentEncodingWithAllowedCharacters( NSCharacterSet.URLQueryAllowedCharacterSet())!
            
            let urlRequest = jsonReqWithAccessToken(urlString, requestType: methodType as String, data: data)
            
            //CREATE A TASK WITH REQUEST
            createTaskWithRequest(urlRequest, showLoader: showLoader, completion: completion, failure: failure)
            
        }catch
        {
            //END TASK _ FAILURE
            endTaskWithFailure(showLoader, failure: failure)
        }
    }
    
    func createTaskWithRequest(urlRequest : NSMutableURLRequest, showLoader: Bool,completion: (result: [String:AnyObject]) -> Void, failure:(failurMSG: NSString)->())
    {
        let task : NSURLSessionDataTask! = NSURLSession.sharedSession().dataTaskWithRequest(urlRequest) {
            (data, response, error) in
            
            if let _ = error
            {
                dispatch_async(dispatch_get_main_queue(), {
                    if showLoader {
                        Spiner.deactivate()
                    }
                   
                    failure(failurMSG:  (error?.localizedDescription)!)
                })
                
            }else{
                
                do {
                    
                    let dict = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as! [String:AnyObject]
                    
                    completion(result:dict)
                    
                }catch{
                    dispatch_async(dispatch_get_main_queue(), {
                        if showLoader {
                            Spiner.deactivate()
                        }
                    })
                    failure(failurMSG: STRINGVALUES.FAILURE_MESSAGE)
                    
                }
            }
        }
        
        task.resume()
    }
    
    func endTaskWithFailure(showLoader: Bool, failure:(failurMSG: NSString)->())
    {
        dispatch_async(dispatch_get_main_queue(),
                       {
                        if showLoader {
                            Spiner.deactivate()
                        }
        })
        failure(failurMSG: STRINGVALUES.SERVER_TIMEOUT)
    }
    
    func endTaskWithFailureInternet(showLoader: Bool, failure:(failurMSG: NSString)->())
    {
        dispatch_async(dispatch_get_main_queue(),
                       {
                        if showLoader {
                            Spiner.deactivate()
                        }
        })
        failure(failurMSG: InternetMessage.MSGInternet)
    }
    
    func postRequestUsingDictionaryParameters(requestType : String, urlComponent : String, inputParameters : NSDictionary, completion: (result : NSData, httpResponse : NSHTTPURLResponse) -> Void, failure:(error: NSError) ->()){
        
        let urlString: String = "\(API.BASE_URL)\(urlComponent)"
        do {
            
            let jsonData = try NSJSONSerialization.dataWithJSONObject(inputParameters, options: NSJSONWritingOptions.PrettyPrinted)
            let jsonString = NSString(data: jsonData, encoding: NSUTF8StringEncoding)! as String
            let data = jsonString.dataUsingEncoding(NSASCIIStringEncoding, allowLossyConversion: false)
            
            
            let request = jsonReqWithAccessToken(urlString, requestType: requestType, data: data!)
            
            
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
                guard error == nil && data != nil else {
                    // check for fundamental networking error
                    print("error=\(error)")
                    return
                }
                if error != nil {
                    failure (error: error!)
                } else {
                    
                    completion(result: data!, httpResponse: (response as? NSHTTPURLResponse)!)
                }
            }
            
            task.resume()
            
        }
        catch let error as NSError {
            print(error)
        }
    }
    
    func jsonReq(urlString : String, requestType : String,data : NSData) -> NSMutableURLRequest
    {
        
        let request = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        request.HTTPMethod = requestType
        request.HTTPBody = data
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        
        return request
    }
    
    func jsonReqWithAccessToken(urlString : String, requestType : String,data : NSData) -> NSMutableURLRequest
    {
        let request = jsonReq(urlString, requestType: requestType, data: data)
        
        //PASS ACCESS TOKEN
        let credentials = "admin"+":"+"123"
        let accessToken = "Basic "+credentials.toBase64()
        
        
        request.setValue(accessToken, forHTTPHeaderField: "Authorization")
        
        return request
    }
    
    func requestTokenAgain(urlComponent : String, inputParameters : String , requestType : String, completion: (result : NSData, httpResponse : NSHTTPURLResponse) -> Void, failure:(error: NSError) ->())
    {
        
        let urlString: String = "\(API.BASE_URL)\(urlComponent)"
        
        let data = inputParameters .dataUsingEncoding(NSUTF8StringEncoding)
        
        let request = jsonReqWithAccessToken(urlString, requestType: requestType, data: data!)
        
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
            guard error == nil && data != nil else {
                // check for fundamental networking error
                print("error=\(error)")
                return
            }
            
            if error != nil {
                //                    failure (error: error!)
            }  else {
                
                
                let httpStatus = response as? NSHTTPURLResponse
                
                if httpStatus?.statusCode ==  APIRESPONSECODE.SUCCESS {
                    completion(result: data!, httpResponse: (response as? NSHTTPURLResponse)!)
                }
            }
        }
        task.resume()
    }
}


// MARK: USING SCHEME II
// Using LOGIC IF ACCESS TOKEN  EXPIRE, THEN GO FOR REFRESH TOKEN AND HIT AGAIN ELSE MOVE TO LOGIN SCREEN

// New Code Testing

func postRequestUsingDictionaryParameters_REF_TOKEN(requestType : String, urlComponent : String, inputParameters : NSDictionary, completion: (result : NSData, httpResponse : NSHTTPURLResponse) -> Void, failure:(error: NSError) ->()){
    
    let accessToken : String = ""
    let urlString: String = "\(API.BASE_URL)\(urlComponent)"
    do {
        
        let jsonData = try NSJSONSerialization.dataWithJSONObject(inputParameters, options: NSJSONWritingOptions.PrettyPrinted)
        let jsonString = NSString(data: jsonData, encoding: NSUTF8StringEncoding)! as String
        let data = jsonString.dataUsingEncoding(NSASCIIStringEncoding, allowLossyConversion: false)
        
        
        let request = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        request.HTTPMethod = requestType
        request.HTTPBody = data
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/Json", forHTTPHeaderField: "Accept")
        request.setValue(accessToken, forHTTPHeaderField: "Authorization")
        
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
            guard error == nil && data != nil else {
                // check for fundamental networking error
                Helper.FGSLog("error=\(error)")
                failure(error: error!)
                return
            }
            
            do{
                let dict = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as! [String:AnyObject]
                Helper.FGSLog(dict)
                
            }
            catch let error as NSError{
                print(error)
            }
            
            
            let httpStatus = response as? NSHTTPURLResponse
            
            print(httpStatus)
            
            if httpStatus?.statusCode ==  APIRESPONSECODE.BAD_REQUEST {
                
                // Make Request for New Access Token
                
                let refreshToken = ""
                
                let inputparameters = "grant_type=refresh_token&refresh_token=" + refreshToken
                
                print(inputparameters)
                
                requestTokenAgain_REF_TOKEN("token", inputParameters: inputparameters, requestType: "POST", refrshcompletion: { (result, httpResponse) in
                    
                    do {
                        
                        let dict = try NSJSONSerialization.JSONObjectWithData(result, options: .AllowFragments) as! [String:AnyObject]
                        print("Response from Server :", dict)
                        
                        let httpStatus = httpResponse
                        
                        if httpStatus.statusCode == APIRESPONSECODE.BAD_REQUEST{
                            
                            completion(result: result, httpResponse: (response as? NSHTTPURLResponse)!)
                            
                        }
                            
                        else if httpStatus.statusCode == APIRESPONSECODE.SUCCESS{
                            
                            // Now Call Get Details API Again
                            postRequestUsingDictionaryParameters_REF_TOKEN(requestType, urlComponent: urlComponent, inputParameters: inputParameters, completion: completion, failure: failure)
                        }
                        else{
                            
                            // Go back to login screen
                            
                            failure (error: error!)
                        }
                        
                        
                    } catch let error as NSError {
                        print(error)
                    }
                    
                    }, failure: { (error) in
                        
                        print(error)
                        
                })
                
            } else {
                
                if error != nil {
                    failure (error: error!)
                } else {
                    
                    completion(result: data!, httpResponse: (response as? NSHTTPURLResponse)!)
                }
            }
            
            
        }
        task.resume()
    }
    catch let error as NSError {
        print(error)
    }
}


func requestTokenAgain_REF_TOKEN(urlComponent : String, inputParameters : String , requestType : String, refrshcompletion: (result : NSData, httpResponse : NSHTTPURLResponse) -> Void, failure:(error: NSError) ->()){
    
    let accessToken : String = ""
    
    let urlString: String = "\(API.BASE_URL)\(urlComponent)"
    
    let data = inputParameters .dataUsingEncoding(NSUTF8StringEncoding)
    let request = NSMutableURLRequest(URL: NSURL(string: urlString)!)
    request.HTTPMethod = requestType
    request.HTTPBody = data
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("application/Json", forHTTPHeaderField: "Accept")
    request.setValue(accessToken, forHTTPHeaderField: "Authorization")
    
    
    let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
        guard error == nil && data != nil else {
            // check for fundamental networking error
            Helper.FGSLog("error=\(error)")
            
            return
        }
        
        do{
            let dict = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as! [String:AnyObject]
            Helper.FGSLog(dict)
            
        }
        catch let error as NSError{
            print(error)
        }
        
        let httpStatus = response as? NSHTTPURLResponse
        
        print(httpStatus)
        
        refrshcompletion(result: data!, httpResponse: (response as? NSHTTPURLResponse)!)
        
        
    }
    task.resume()
}
