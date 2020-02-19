//
//  DarkSky.swift
//  WeatherHelper
//
//  Created by Telman Rustam on 2019-10-23.
//  Copyright © 2019 com.iballistic. All rights reserved.
//

import Foundation
//https://gist.github.com/cmoulton/7ddc3cfabda1facb040a533f637e74b8
//https://cocoacasts.com/working-with-nsurlcomponents-in-swift
//https://developer.apple.com/documentation/foundation/jsondecoder
@available(OSX 10.12, *)
public class DarkSky : ProviderAPI{
    
    public var temperature : String? = nil
    public var humidity : String? = nil
    public var pressure : String? = nil
    public var windspeed : String? = nil
    public var error : String? = nil
    public var apiKey: String? = nil
    
    public required init(apiKey: String?){
        if let key = apiKey{
            self.apiKey =  key
        }
    }
    //MARK : Get Temprature from DarkSky API
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
        //Required parameters slot directly into the request URL.
        //Optional parameters should be specified as HTTP query parameters.
        //https://api.darksky.net/forecast/[key]/[latitude],[longitude]
        components.scheme = "https"
        components.host = "api.darksky.net"
        components.path =  "/forecast"
        components.path.append("/\(key)")
        components.path.append("/\(latitude),\(longitude)")
        components.queryItems = []
        components.queryItems?.append(URLQueryItem(name: "units", value:"us"))
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
                        case "currently":
                            let main = val as! [String: Any]
                            for (itemKey, itemVal) in main{
                                if itemKey == "temperature"{
                                    self.temperature = "\(itemVal)"
                                }
                                if itemKey == "humidity"{
                                    if let humidity = itemVal as? Double{
                                        self.humidity = "\(humidity * 100)"
                                    }else{
                                        self.humidity = "0"
                                    }
                                }
                                if itemKey == "pressure"{
                                    let base = Measurement(value: Double(itemVal as! Double), unit: UnitPressure.hectopascals )
                                    let converted = base.converted(to: UnitPressure.inchesOfMercury)
                                    self.pressure = "\(converted.value)"
                                    
                                }
                                if itemKey == "windSpeed"{
                                    self.windspeed = "\(itemVal)"
                                }
                            }
                        case "error":
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
