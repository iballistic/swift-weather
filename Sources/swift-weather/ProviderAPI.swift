//
//  ProviderAPI.swift
//  WeatherHelper
//
//  Created by Telman Rustam on 2018-08-15.
//  Copyright © 2018 com.iballistic. All rights reserved.
//

import Foundation

public protocol ProviderAPI {
    var temperature : String? {get}
    var humidity : String? {get}
    var pressure : String? {get}
    var windspeed : String? {get}
    var error : String? {get}
    var apiKey: String? {set get}
    init(apiKey: String?)
    func getWeather(latitude: Double, longitude: Double, onComplete: @escaping ()->Void)
}
