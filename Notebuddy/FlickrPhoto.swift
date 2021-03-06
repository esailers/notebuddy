//
//  FlickrPhoto.swift
//  Notebuddy
//
//  Created by Eric Sailers on 9/3/16.
//  Copyright © 2016 Expressive Solutions. All rights reserved.
//

import Foundation

struct FlickrPhoto {
    
    // MARK: Properties
    let path: String?
    
    // MARK: Initializer
    init(dictionary: [String: Any]) {
        path = dictionary[FlickrClient.JSONResponseKeys.mediumURL] as? String
    }
    
    // Get Flickr photos from results
    static func photosFromResults(_ results: [[String: Any]]) -> [FlickrPhoto] {
        var photos = [FlickrPhoto]()
        
        for result in results {
            photos.append(FlickrPhoto(dictionary: result))
        }
        return photos
    }
    
}
