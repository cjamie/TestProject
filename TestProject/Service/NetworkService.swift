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
}



typealias NetworkingErrors = NetworkService
extension NetworkingErrors{
    enum NetworkError:Error{
        case noResponse
        case responseError(Int)
        case noData
        
        var localizedDescription:String{
            switch self{
            case .noData:
                return "No data"
            case .noResponse:
                return "No response"
            case .responseError(let x):
                return "Bad status code:(\(x))"
            }
        }
    }
}

extension NetworkService{
    private struct API {
        static let base = "https://photo.nemours.org/P/"
    }
    
    enum URLS {
        case person(String)
        
        var string: String {
            switch self {
            case .person(let imageNumber):
                return  API.base + "\(imageNumber)/100x100?type=P"
            }
        }
    }
}



