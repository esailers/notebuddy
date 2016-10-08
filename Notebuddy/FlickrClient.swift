//
//  FlickrClient.swift
//  Notebuddy
//
//  Created by Eric Sailers on 8/26/16.
//  Copyright © 2016 Expressive Solutions. All rights reserved.
//

import CoreData

class FlickrClient {
    
    // MARK: - typealias shorthand for completion handler
    
    typealias FlickrSearchCompletionHandler = (_ photos: [FlickrPhoto]?, _ errorText: String?) -> Void
    
    // MARK: - HTTPMethod enum
    
    enum HTTPMethod: String {
        case GET, POST, PUT, DELETE
    }

    // MARK: - Shared Instance
    
    class func sharedInstance() -> FlickrClient {
        struct Singleton {
            static let sharedInstance = FlickrClient()
        }
        return Singleton.sharedInstance
    }
    
    // MARK: - Requests
    
    // Swift 2.2
    // let task = URLSession.shared().dataTask(with: request)
    
    // Swift 3.0
    // let task = URLSession.shared().dataTask(with: request as URLRequest) {
    
    fileprivate func makeRequestAtURL(_ url: URL, method: HTTPMethod, completionHandler: @escaping (Data?, NSError?) -> Void) {
        let request = NSMutableURLRequest(url: url)
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) in
            
            guard error == nil else {
                return completionHandler(nil, error as NSError?)
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode , statusCode >= 200 && statusCode <= 299 else {
                return completionHandler(nil, error as NSError?)
            }
            
            completionHandler(data, nil)
        }) 
        task.resume()
    }
    
    func resultsFromFlickrSearch(_ text: String, completionHandler: @escaping FlickrSearchCompletionHandler) {
        let methodParameters: [String: AnyObject] = [
            FlickrClient.ParameterKeys.safeSearch: FlickrClient.ParameterValues.useSafeSearch as AnyObject,
            FlickrClient.ParameterKeys.text: text as AnyObject,
            FlickrClient.ParameterKeys.extras: FlickrClient.ParameterValues.mediumURL as AnyObject,
            FlickrClient.ParameterKeys.apiKey: FlickrClient.ParameterValues.apiKey as AnyObject,
            FlickrClient.ParameterKeys.method: FlickrClient.ParameterValues.searchMethod as AnyObject,
            FlickrClient.ParameterKeys.format: FlickrClient.ParameterValues.responseFormat as AnyObject,
            FlickrClient.ParameterKeys.noJSONCallback: FlickrClient.ParameterValues.disableJSONCallback as AnyObject,
            FlickrClient.ParameterKeys.perPage: FlickrClient.ParameterValues.defaultPerPage as AnyObject
        ]
        
        let session = URLSession.shared
        let request = URLRequest(url: FlickrClient.sharedInstance().flickrURLFromParameters(methodParameters))
        
        let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
            
            // Guard: Was there an error?
            guard error == nil else {
                return completionHandler(nil, "There was an error with your request.")
            }
            
            // Guard: Did we get a successful 2XX response?
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode , statusCode >= 200 && statusCode <= 299 else {
                return completionHandler(nil, "There was not a successful 2XX response.")
            }
            
            // Guard: Was there any data returned?
            guard let data = data else {
                return completionHandler(nil, "No data was returned by the request.")
            }
            
            self.parseJSON(data, completionHandler: completionHandler)
        }) 
        task.resume()
    }
    
    // MARK: - Parse the JSON data
    
    fileprivate func parseJSON(_ data: Data, completionHandler: FlickrSearchCompletionHandler) {
        let parsedResult: [String: Any]!
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: Any]
        } catch {
            return completionHandler(nil, "Could not parse the data as JSON: '\(data)'.")
        }
        
        guard let photosDictionary = parsedResult[FlickrClient.JSONResponseKeys.photos] as? [String: Any], let photoArray = photosDictionary[FlickrClient.JSONResponseKeys.photo] as? [[String: Any]] else {
            return completionHandler(nil, "Could not find keys \(FlickrClient.JSONResponseKeys.photos) and \(FlickrClient.JSONResponseKeys.photo) in \(parsedResult).")
        }
        
        let photos: [FlickrPhoto] = FlickrPhoto.photosFromResults(photoArray)
        completionHandler(photos, nil)
    }
    
    // MARK: - Get a photo
    
    func imageDataForPhoto(_ flickrPhoto: FlickrPhoto, completionHandler: @escaping (_ imageData: Data?, _ error: NSError?) -> Void) {
        if let path = flickrPhoto.path, let url = URL(string: path) {
            makeRequestAtURL(url, method: .GET) { (data, error) in
                
                guard error == nil else {
                    completionHandler(nil, error as NSError?)
                    return
                }
                
                completionHandler(data, nil)
            }
        }
    }
    
    // MARK: - Construct URL
    
    fileprivate func flickrURLFromParameters(_ parameters: [String:AnyObject]) -> URL {
        var components = URLComponents()
        components.scheme = Components.scheme
        components.host = Components.host
        components.path = Components.path
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
    }

}
