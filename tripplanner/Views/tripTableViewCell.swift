//
//  tripTableViewCell.swift
//  tripplanner
//
//  Created by user196869 on 8/12/21.
//

import Foundation
import UIKit

class tripTableViewCell:UITableViewCell
{
    @IBOutlet weak var weatherImage: UIImageView!
    
    @IBOutlet weak var lblCity: UILabel!
    
    @IBOutlet weak var lblTemp: UILabel!
    
    var thisTrip : TripInfo?
    {
        didSet{
            let cityName:String = thisTrip!.city!
            let urlCityName:String = cityName.replacingOccurrences(of: " ", with: "%20")
            Service.shared.getUrlInfo(url: "https://api.openweathermap.org/data/2.5/weather?q=\(urlCityName)&units=metric", NeedsKey: true){(data) in
                //parse info
                if let weatherInfo = try? JSONDecoder().decode(WeatherInfo.self, from: data)
                {
                    DispatchQueue.main.async {[unowned self]in
                        //formats for temperature
                        let mf = MeasurementFormatter()
                        mf.locale = Locale(identifier: "en_GB")
                        let temp = Measurement(value: weatherInfo.main.temp, unit: UnitTemperature.celsius)
                        //set label values
                        self.lblTemp.text = mf.string(from: temp)
                        self.lblCity.text = cityName
                        Service.shared.getUrlInfo(url: "http://openweathermap.org/img/wn/\(weatherInfo.weather[0].icon)@2x.png"){(data) in
                            DispatchQueue.main.async {[unowned self]in
                                self.weatherImage.image = UIImage(data:data)
                        }
                    }
                }
            }
        }
        }
        
    }
}
