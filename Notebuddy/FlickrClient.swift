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
    
    typealias FlickrSearchCompletionHandler = (photos: [FlickrPhoto]?, errorText: String?) -> Void
    
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
    
    private func makeRequestAtURL(url: NSURL, method: HTTPMethod, completionHandler: (NSData?, NSError?) -> Void) {
        let request = NSMutableURLRequest(URL: url)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) in
            
            guard error == nil else {
                return completionHandler(nil, error)
            }
            
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                return completionHandler(nil, error)
            }
            
            completionHandler(data, nil)
        }
        task.resume()
    }
    
    func resultsFromFlickrSearch(text: String, completionHandler: FlickrSearchCompletionHandler) {
        let methodParameters: [String: AnyObject] = [
            FlickrClient.ParameterKeys.safeSearch: FlickrClient.ParameterValues.useSafeSearch,
            FlickrClient.ParameterKeys.text: text,
            FlickrClient.ParameterKeys.extras: FlickrClient.ParameterValues.mediumURL,
            FlickrClient.ParameterKeys.apiKey: FlickrClient.ParameterValues.apiKey,
            FlickrClient.ParameterKeys.method: FlickrClient.ParameterValues.searchMethod,
            FlickrClient.ParameterKeys.format: FlickrClient.ParameterValues.responseFormat,
            FlickrClient.ParameterKeys.noJSONCallback: FlickrClient.ParameterValues.disableJSONCallback,
            FlickrClient.ParameterKeys.perPage: FlickrClient.ParameterValues.defaultPerPage
        ]
        
        let session = NSURLSession.sharedSession()
        let request = NSURLRequest(URL: FlickrClient.sharedInstance().flickrURLFromParameters(methodParameters))
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            // Guard: Was there an error?
            guard error == nil else {
                return completionHandler(photos: nil, errorText: "There was an error with your request.")
            }
            
            // Guard: Did we get a successful 2XX response?
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                return completionHandler(photos: nil, errorText: "There was not a successful 2XX response.")
            }
            
            // Guard: Was there any data returned?
            guard let data = data else {
                return completionHandler(photos: nil, errorText: "No data was returned by the request.")
            }
            
            self.parseJSON(data, completionHandler: completionHandler)
        }
        task.resume()
    }
    
    // MARK: - Parse the JSON data
    
    private func parseJSON(data: NSData, completionHandler: FlickrSearchCompletionHandler) {
        let parsedResult: AnyObject!
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
        } catch {
            return completionHandler(photos: nil, errorText: "Could not parse the data as JSON: '\(data)'.")
        }
        
        guard let photosDictionary = parsedResult[FlickrClient.JSONResponseKeys.photos] as? [String: AnyObject], photoArray = photosDictionary[FlickrClient.JSONResponseKeys.photo] as? [[String: AnyObject]] else {
            return completionHandler(photos: nil, errorText: "Could not find keys \(FlickrClient.JSONResponseKeys.photos) and \(FlickrClient.JSONResponseKeys.photo) in \(parsedResult).")
        }
        
        let photos: [FlickrPhoto] = FlickrPhoto.photosFromResults(photoArray)
        completionHandler(photos: photos, errorText: nil)
    }
    
    // MARK: - Get a photo
    
    func imageDataForPhoto(flickrPhoto: FlickrPhoto, completionHandler: (imageData: NSData?, error: NSError?) -> Void) {
        if let path = flickrPhoto.path, url = NSURL(string: path) {
            makeRequestAtURL(url, method: .GET) { (data, error) in
                
                guard error == nil else {
                    completionHandler(imageData: nil, error: error)
                    return
                }
                
                completionHandler(imageData: data, error: nil)
            }
        }
    }
    
    // MARK: - Construct URL
    
    private func flickrURLFromParameters(parameters: [String:AnyObject]) -> NSURL {
        let components = NSURLComponents()
        components.scheme = Components.scheme
        components.host = Components.host
        components.path = Components.path
        components.queryItems = [NSURLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = NSURLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.URL!
    }

}
