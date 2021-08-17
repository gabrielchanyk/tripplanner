//
//  Validation.swift
//  tripplanner
//
//  Created by user196869 on 8/17/21.
//

import Foundation
import CoreData

class Validation
{
    //shared property to be accessed outside
    static var shared = Validation()
    //private init for singleton to not be created or modified
    private init() {}
    //validate city with weather api to see if its supported
    func validateCity (city:String, completion: @escaping (Bool)->Void)
    {
        //replaces spaces to %20
        let urlCityName = city.replacingOccurrences(of: " ", with: "%20")
    
        //use getInfo to get info from url
        Service.shared.getUrlInfo(url: "https://api.openweathermap.org/data/2.5/weather?q=\(urlCityName)&units=metric", NeedsKey: true){(apiData) in
            //check if there is data
            if  (String (data: apiData, encoding: .utf8)) != nil
            {
                //set true to completion
                completion(true)
            }
        }
    }
}
