//
//  ApiService.swift
//  AlamofireTest
//
//  Created by Fantastic on 03/03/17.
//  Copyright © 2017 Fantastic. All rights reserved.
//

import UIKit
import Alamofire

class ApiService {
    static let sharedInstance = ApiService()
    var sessionManager = Alamofire.SessionManager()
    
    func getData(start: Int, count: Int, onSuccess:@escaping (_ result: DataResponse<Any>) -> Void, onFailure:@escaping (_ error: Error) -> Void) {
        let url = String(format: Constants.API.baseURL, start, count)
        self.sessionManager.request(url).responseJSON { response in
            switch response.result {
            case .success:
                onSuccess(response)
            case .failure(let error):
                onFailure(error)
            }
        }
    }    
}
