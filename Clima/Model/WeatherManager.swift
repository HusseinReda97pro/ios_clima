//
//  WeatherManager.swift
//  Clima
//
//  Created by Hussein Reda on 19/09/2024.
//  Copyright © 2024 App Brewery. All rights reserved.
//

import Foundation
import CoreLocation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager:WeatherManager, wether: WeatherModel)
    func didFailWithError(error:Error)
}

struct WeatherManager {
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=8fbfabdfee51724e34110b5b99465e36&units=metric"
    
    var delegate:WeatherManagerDelegate?
    
    func fetchWeather(cityName:String){
        let urlString = "\(weatherURL)&q=\(cityName)"
        print(urlString)
        performRequesr(with:urlString)
    }
    
    func fetchWeather(lat:CLLocationDegrees,lon:CLLocationDegrees){
        let urlString = "\(weatherURL)&lat=\(lat)&lon=\(lon)"
        print(urlString)
        performRequesr(with:urlString)
    }
    
    
    
    func performRequesr(with urlString:String){
        if let url = URL(string:urlString) {
            let session = URLSession(configuration: .default)
            
            //           let task = session.dataTask(with: url,completionHandler:handler(data: response: error:))
            let task = session.dataTask(with: url) { data , response, error in
                if(error != nil){
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                
                if let safeData = data {
                    if let weather =  self.parseJSON(safeData){
                        self.delegate?.didUpdateWeather(self,wether: weather)
                    }
                }
            }
            
            task.resume()
        }
    }
    
    
    func parseJSON(_ weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let name = decodedData.name
            let temp = decodedData.main.temp
            let id = decodedData.weather[0].id
            
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
            
            return weather
        } catch {
            self.delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
   
}
