//
//  NetworkManager.swift
//  Project38
//
//  Created by Niraj on 07/12/2019.
//  Copyright © 2019 Niraj. All rights reserved.
//

import Foundation


class NetworkManager {

    typealias ResponseType = (Result<Data, Error>) -> Void

    private init() {

    }

    private static let _sharedInstance = NetworkManager()

    class func sharedInstance() -> NetworkManager {
        return _sharedInstance
    }

    func requestData(for urlPath:URL, completionHandler:@escaping (ResponseType)) {
        let urlSession = URLSession.shared

        let task = urlSession.dataTask(with: urlPath) { (data, _, error) in
            guard let data = data else {
                completionHandler(.failure((error)!))
                return
            }

            completionHandler(.success(data))
         }
        task.resume()
    }

}

