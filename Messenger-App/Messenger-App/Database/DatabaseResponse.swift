//
//  DatabaseResponse.swift
//  Messenger-App
//
//  Created by MacBook on 16.02.2021.
//

import Foundation


enum DatabaseResponse <T, U: Error> {
    
    case success(T)
    case failure(U)
    
}

enum DatabaseError: Error {
    
    case failedToUpload
    case failedToGetDownloadURL
    case failedToFetch

    
}
