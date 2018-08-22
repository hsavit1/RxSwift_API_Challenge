//
//  RecipeAPI.swift
//  RecipePuppyChallenge
//
//  Created by Henry Savit on 8/21/18.
//  Copyright © 2018 HenrySavit. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire

enum ApiRequestError: Error {
    case statusCodeOtherThan200(statusCode: Int)
    // other error cases will be added here
}

enum ApiResponse {
    case success(Data)
    case failure(Error)
}

typealias myCompletionHandler = (ApiResponse) -> ()

class RecipeAPI {
    
    static func getRecipes(with recipeName: String) -> Observable<AnyObject> {
        let url = Keys.rootPath + Keys.queryPath + "\(recipeName)"
        
        return Observable.create { observer in
            let request = Alamofire.request(url, method: .get).responseJSON(completionHandler: { response in
            
                    switch (response.result) {
                    case .success(let data):
                        //do json stuff
                        
                        observer.on(.next(data as AnyObject))
                        observer.on(.completed)
                        break
                    case .failure(let error):
                        if error._code == NSURLErrorTimedOut {
                            //HANDLE TIMEOUT HERE
                            observer.on(.error(error))
                        }
                        print("\n\nAuth request failed with error:\n \(error)")
                        break
                    }
            })
            return Disposables.create {
                request.cancel()
            }
        }
    }
    
    static func getRecipes(with recipeName: String, completion: @escaping (Any)->Void) {
        let url = URL(string: Keys.rootPath + Keys.queryPath + "\(recipeName)")
        guard url != nil else {return}
        
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                
                // check for fundamental networking error
                guard let data = data, error == nil else {
                    print("error=\(error.debugDescription)")
                    return
                }
                
                // check for http errors
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                    print("statusCode should be 200, but is \(httpStatus.statusCode)")
                    print("response = \(response.debugDescription)")
                    return
                }
                completion(data)
            }
        }
        task.resume()
    }
}

struct Keys {
    static let rootPath: String = "http://www.recipepuppy.com/api/"
    static let queryPath: String = "?i="
}

