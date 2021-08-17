//
//  Service.swift
//  weatherApp
//
//  Created by user196869 on 8/8/21.
//

//need to set http better security
//add error checking


import Foundation
import CoreData

class Service
{
    //shared property to be accessed outside of class
    static var shared = Service()
    //private init for singleton to not be created or modified
    private init() {}
    //api key needed for weather api
    let api_key_Value = "ded388681846803c7e3037ba69d36d17"
    
    //get info from url
    func getUrlInfo(url:String,NeedsKey:Bool = false, completion: @escaping (Data) ->Void){
        //set variable to hold url string
        var urlString:String
        //check if url needs key
        if NeedsKey
        {
            //add key to url string
            urlString = url + "&appid=\(api_key_Value)"
        }
        else
        {
            //urlString set to what was given
            urlString = url
        }
        
        //validate url
        guard let url = URL(string: urlString) else {
            return
        }
        //start task to getinfo from url
        let getUrlInfo = URLSession.shared.dataTask(with: url) { (data, response, error) in
            //check for errors
            if let error = error {
                self.handleClientError(error:error)
                return
            }
            //check for responses
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                self.handleServerError(response:response)
                return
            }
            //validate data
            if let data = data
            {
                //send completion
                completion(data)
            }
        }
        //start task
        getUrlInfo.resume()
    }
    
    //handle server error
    func handleServerError(response:URLResponse?)
    {
        //print response for logging
        print (response ?? "")
    }
    //handle client error
    func handleClientError(error:Error)
    {
        //print  error for logging
        print(error)
    }
}
