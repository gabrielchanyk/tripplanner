//
//  Codables.swift
//  tripplanner
//
//  Created by user196869 on 8/12/21.
//

import Foundation
class WeatherInfo :Codable
{
    //main is the key were info is
    var main : tempInfo
    var weather: [ImageInfo]
}

class ImageInfo: Codable
{
    var icon : String
}

class tempInfo:Codable
{
    var temp : Double
}
