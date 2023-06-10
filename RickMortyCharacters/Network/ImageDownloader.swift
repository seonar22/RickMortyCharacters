//
//  ImageDownloader.swift
//  RickMortyCharacters
//
//  Created by MAC on 6/10/23.
//

import Foundation

protocol ImageDownloaderCapablities {
    func download(url: URL, toFile file: URL, completion: @escaping (Error?) -> Void)
    func loadData(url: URL, completion: @escaping (Data?, Error?) -> Void)
}

class ImageDownloader: ImageDownloaderCapablities {
    static let shared = ImageDownloader()
    
    private init () {}
    
    func download(url: URL, toFile file: URL, completion: @escaping (Error?) -> Void) {
        // Download the remote URL to a file
        let task = URLSession.shared.downloadTask(with: url) {
            (tempURL, response, error) in
            // Early exit on error
            guard let tempURL = tempURL else {
                completion(error)
                return
            }
            
            do {
                if FileManager.default.fileExists(atPath: file.path) {
                    try FileManager.default.removeItem(at: file)
                }
                
                try FileManager.default.copyItem(
                    at: tempURL,
                    to: file
                )
                
                completion(nil)
            } catch let fileError {
                completion(fileError)
            }
        }
        task.resume()
    }

    func loadData(url: URL, completion: @escaping (Data?, Error?) -> Void) {
        // Compute a path to the URL in the cache
        let cachedFilePath = FileManager.default.temporaryDirectory
            .appendingPathComponent(
                url.lastPathComponent,
                isDirectory: false
            )
        
        
        if let data = try? Data(contentsOf: cachedFilePath.absoluteURL) {
            completion(data, nil)
            return
        }
        
        download(url: url, toFile: cachedFilePath) { (error) in
            let data = try? Data(contentsOf: cachedFilePath.absoluteURL)
            completion(data, error)
        }
    }
}
