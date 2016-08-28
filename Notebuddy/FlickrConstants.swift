//
//  FlickrConstants.swift
//  Notebuddy
//
//  Created by Eric Sailers on 8/26/16.
//  Copyright © 2016 Expressive Solutions. All rights reserved.
//

extension FlickrClient {
    
    // MARK: Components
    
    struct Components {
        static let scheme = "https"
        static let host = "api.flickr.com"
        static let path = "/services/rest"
    }
    
    // MARK: Parameter Keys
    
    struct ParameterKeys {
        static let method = "method"
        static let apiKey = "api_key"
        static let extras = "extras"
        static let format = "format"
        static let noJSONCallback = "nojsoncallback"
        static let safeSearch = "safe_search"
        static let text = "text"
        static let perPage = "per_page"
    }
    
    // MARK: Parameter Values
    
    struct ParameterValues {
        static let searchMethod = "flickr.photos.search"
        static let apiKey = "ea6c3642a93a64906a00a2f77242f058"
        static let responseFormat = "json"
        static let disableJSONCallback = "1" /* 1 means "yes" */
        static let mediumURL = "url_m"
        static let useSafeSearch = "1" /* 1 means "yes" */
        static let defaultPerPage = 20 /* Default is 100 */
    }
    
    // MARK: JSON Response Keys
    
    struct JSONResponseKeys {
        static let status = "status"
        static let photos = "photos"
        static let photo = "photo"
        static let title = "title"
        static let mediumURL = "url_m"
        static let pages = "pages"
        static let total = "total"
    }
    
    // MARK: JSON Response Values
    
    struct JSONResponseValues {
        static let okStatus = "ok"
    }
    
}
