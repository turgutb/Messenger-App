

import Foundation
import Firebase
import FirebaseAuth
import FirebaseStorage

class StorageManager {
    
    static let shared = StorageManager()
    private let storage = Storage.storage().reference()
    let userID = Auth.auth().currentUser?.uid
    public typealias UploadPictureCompletion = (Result<String, Error>) -> Void
    
    
    
    public func uploadProfilePicture(with data: Data, fileName: String, completion: @escaping (Result <String, Error>) -> Void)  {
        
        storage.child("images/\(fileName)").putData(data, metadata: nil, completion: { metadata, error in
            guard error == nil else  {
                
                print("failed to upload data to firebase for picture")
                completion(.failure(DatabaseError.failedToUpload))
                
                return
            }
            
            self.storage.child("images/\(fileName)").downloadURL(completion: { url, error in
                
                guard let url = url else {
                    print("Failed to get download url")
                    completion(.failure(DatabaseError.failedToGetDownloadURL))
                    return
                }
                
                let urlString = url.absoluteString
                print("download url returned: \(urlString)")
                completion(.success(urlString))
                
            })
            
        })
        
    }
    
    public func uploadMessagePhoto(with data: Data, fileName: String, completion: @escaping UploadPictureCompletion) {
        storage.child("message_images/\(fileName)").putData(data, metadata: nil, completion: { [weak self] metadata, error in
            guard error == nil else {
                print("failed to upload data to firebase for picture")
                completion(.failure(DatabaseError.failedToUpload))
                return
            }
            
            self?.storage.child("message_images/\(fileName)").downloadURL(completion: { url, error in
                guard let url = url else {
                    print("Failed to get download url")
                    completion(.failure(DatabaseError.failedToGetDownloadURL))
                    return
                    
                }
                
                let urlString = url.absoluteString
                print("download url returned: \(urlString)")
                completion(.success(urlString))
                
            })
        })
    }
    
    public func uploadMessageVideo(with fileUrl: URL, fileName: String, completion: @escaping UploadPictureCompletion) {
        storage.child("message_videos/\(fileName)").putFile(from: fileUrl, metadata: nil, completion: { [weak self] metadata, error in
            guard error == nil else {
                // failed
                print("failed to upload video file to firebase for picture")
                completion(.failure(DatabaseError.failedToUpload))
                return
            }

            self?.storage.child("message_videos/\(fileName)").downloadURL(completion: { url, error in
                guard let url = url else {
                    print("Failed to get download url")
                    completion(.failure(DatabaseError.failedToGetDownloadURL))
                    return
                }

                let urlString = url.absoluteString
                print("download url returned: \(urlString)")
                completion(.success(urlString))
            })
        })
    }
        
    
    
    public func downloadURL(for path: String, completion: @escaping (Result<URL, Error>) -> Void) {
        let reference = storage.child(path)
        
        reference.downloadURL(completion: { url, error in
            guard let url = url, error == nil else {
                completion(.failure(DatabaseError.failedToGetDownloadURL))
                return
            }
            
            completion(.success(url))
        })
    }
}


