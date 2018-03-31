//
//  Service.swift
//  TestProject
//
//  Created by Admin on 2/26/18.
//  Copyright © 2018 Patel, Sanjay. All rights reserved.
//

import UIKit

class NetworkService {
    
    
    static func downloadImage(from url:String,completion:@escaping(UIImage?,Error?)->()){
        
        let input = URLS.person(url).string
        guard let uurl = URL(string:input) else {return}
        let session = URLSession.shared
        session.invalidateAndCancel()
        _ = session.dataTask(with: uurl) {
            (data, response, error) in
            guard error == nil else{
                completion(nil, error)
                return
            }
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode else{
                completion(nil, NetworkError.noResponse)
                return
            }
            guard statusCode == 200 else{
                completion(nil, NetworkError.responseError(statusCode))
                return
            }
            guard let data = data else{
                completion(nil, NetworkError.noData)
                return
            }
            guard let image = UIImage(data:data) else {return}
            completion(image, nil)
            
            }.resume()
    }
    
    static func downloadPokemon(for Id: Int, completion: @escaping(Pokemon?, Error?)->()){
        
        
        let input = URLS.pokemon(Id).string
        guard let url = URL(string:input) else {return}
        
        var request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 4*60*60) //cached for 4 hours
        //        request.addValue("\(60*60)", forHTTPHeaderField: "Cache-Control")
        request.addValue("Cache-Control: max-age=\(4*60*60)", forHTTPHeaderField: "Cache-Control")
        
        _ = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            
            guard error == nil else{
                completion(nil, error)
                return
            }
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode else{
                completion(nil, NetworkError.noResponse)
                return
            }
            guard statusCode == 200 else{
                completion(nil, NetworkError.responseError(statusCode))
                return
            }
            guard let data = data else{
                completion(nil, NetworkError.noData)
                return
            }
            
            do {
                let tempPokemon = try JSONDecoder().decode(Pokemon.self, from: data)
                completion(tempPokemon, nil)
            }catch{
                completion(nil, NetworkError.invalidJSON)
            }
            }.resume()
    }
}



typealias NetworkingErrors = NetworkService
extension NetworkingErrors{
    enum NetworkError:Error{
        case noResponse
        case responseError(Int)
        case noData
        case invalidJSON
        case badImage
        
        var localizedDescription:String{
            switch self{
            case .noData:
                return "No data"
            case .noResponse:
                return "No response"
            case .responseError(let x):
                return "Bad status code:(\(x))"
            case .invalidJSON:
                return "Problem parsing data"
            case .badImage:
                return "Not an Image"
            }
        }
    }
}

extension NetworkService{
    private struct API {
        static let base = "https://photo.nemours.org/P/"
        static let pokemonBase = "http://pokeapi.co/api/v2/pokemon/"

    }
    
    enum URLS {
        case person(String)
        case pokemon(Int)
        
        var string: String {
            switch self {
            case .person(let imageNumber):
                return  API.base + "\(imageNumber)/100x100?type=P"
            case .pokemon(let num):
                return API.pokemonBase + "\(num)/"
            }
        }
    }
}



