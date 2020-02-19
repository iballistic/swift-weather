//
//  OpenWeather.swift
//  WeatherHelper
//
//  Created by Telman Rustam on 2019-10-04.
//  Copyright © 2019 com.iballistic. All rights reserved.
//

import Foundation
//https://gist.github.com/cmoulton/7ddc3cfabda1facb040a533f637e74b8
//https://cocoacasts.com/working-with-nsurlcomponents-in-swift
//https://developer.apple.com/documentation/foundation/jsondecoder

@available(OSX 10.12, *)
public class OpenWeather : ProviderAPI{
    
    public var temperature : String? = nil
    public var humidity : String? = nil
    public var pressure : String? = nil
    public var windspeed : String? = nil
    public var error : String? = nil
    public var apiKey: String? = nil
    
    public required init(apiKey: String?){
        if let key = apiKey{
            self.apiKey = key
        }
    }
    //MARK : Get Temprature from OpenWeather API
    /// <#Description#>
    ///Get Temprature from OpenWeather API
    /// - Parameters:
    ///   - latitude: latitude of the current location
    ///   - longitude: longitude of the current location
    ///   - onComplete: closure to be executed on successful execution only. Otherwise self.error to be used to show error.
    public func getWeather(latitude: Double, longitude: Double, onComplete: @escaping ()->Void){
        
        guard let key = self.apiKey else{
            return
        }
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.openweathermap.org"
        components.path =  "/data/2.5/weather"
        components.queryItems = []
        components.queryItems?.append(URLQueryItem(name: "lat", value:"\(latitude)"))
        components.queryItems?.append(URLQueryItem(name: "lon", value:"\(longitude)"))
        components.queryItems?.append(URLQueryItem(name: "units", value:"imperial"))
        components.queryItems?.append(URLQueryItem(name: "appid", value: key))
        
        print(components.url!)
        // set up the session
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        let urlRequest = URLRequest(url: components.url!)
        let task = session.dataTask(with: urlRequest){
            (data, response, error) in
            guard let _ = response else{
                self.error = "Unable to connect to OpenWeather API"
                return
            }
            guard let result = data else{
                self.error = "Unable to get data from OpenWeather Service"
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: result, options: []) as? [String: Any]
                if let dataDict : [String: Any] = json{
  
                    for(key,val) in dataDict{
                        switch key{
                        case "main":
                            let main = val as! [String: Any]
                            for (itemKey, itemVal) in main{
                                if itemKey == "temp"{
                                    self.temperature = "\(itemVal)"
                                }
                                if itemKey == "humidity"{
                                    self.humidity = "\(itemVal)"
                                }
                                if itemKey == "pressure"{
                                    let base = Measurement(value: Double(itemVal as! Double), unit: UnitPressure.hectopascals )
                                    let converted = base.converted(to: UnitPressure.inchesOfMercury)
                                    self.pressure = "\(converted.value)"
                                    
                                }
                            }
                        case "wind":
                            let units = val as! [String: Any]
                            for (itemKey, itemVal) in units{
                                if itemKey == "speed"{
                                    self.windspeed = "\(itemVal)"
                                }
                            }
                        case "message":
                            if let message = val as? String{
                                self.error = "\(message)"
                            }
   
                        default:
                            print("key: \(key), val: \(val)")
                        }
                    }
                    
                }
                
                onComplete()
            } catch{
                self.error = "Unable to process data"
                return
            }
            
        }
        
        
        
        task.resume()
        
    }
}
