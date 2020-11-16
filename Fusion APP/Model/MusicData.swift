//
//  MusicData.swift
//  Fusion APP
//
//  Created by Cooper on 2020/11/14.
//

import Foundation
import UIKit

struct SongResults: Codable {
    let resultCount: Int
    let results: [MusicInfo]
}


//MARK: Music API DATA
struct MusicInfo: Codable {
    let artistName: String
    let collectionName: String
    let trackName: String
    let previewUrl: URL
    let artworkUrl100: URL
    let releaseDate: String
    let isStreamable: Bool
    
    //將圖片放大至1000x1000，透過deletingLastPathComponent()，去掉後面的100x100bb.jpg，變成1000x1000
    //https://is4-ssl.mzstatic.com/image/thumb/Music118/v4/b3/9e/6a/b39e6a43-7674-3d0a-8fb4-8c52348de2e9/source/100x100bb.jpg
    var artworkUrl1000: URL{
        artworkUrl100.deletingLastPathComponent().appendingPathComponent("1000x1000bb.jpg")
    }
    
}


//MARK: 共用抓 API 方法
internal struct MusicController {
    
    static let shared = MusicController()
    
    //@escaping可以讓傳入(自己取的名：completion）的function在 func fetchMusic 這個執行完畢後還能繼續使用。因為URLSession的關係，這裡需要使用@escaping。
    func fetchMusic(completion: @escaping ([MusicInfo]?) -> ()) {
        let url = "https://itunes.apple.com/search?term=avicii&media=music"
        let decoder = JSONDecoder()
        
        if let url = URL(string: url) {
            decoder.dateDecodingStrategy = .iso8601
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let data = data,
                   //MARK: 解析data
                   let musicData = try? decoder.decode(SongResults.self, from: data) {
                    completion(musicData.results)
                } else {
                    completion(nil)
                }
            }.resume()
        }
        
    }
    
}

    
    
    
    
    

    
    
    


