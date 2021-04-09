//
//  Network.swift
//  MesaNews
//
//  Created by Fernando Carneiro on 08/04/21.
//

import Foundation

class NetworkManager{
    let imageCache = NSCache<NSString,NSData>()
    
    //Singleton para conexão
    static let shared = NetworkManager()
    private init() { }
    private let baseUrlString = "https://newsapi.org/v2/"
    private let USTopHeadline = "top-headlines?country=us"

    //Pegar notícias, também a definição da sessão
    func getNews(completion: @escaping ([News]?) -> Void){
        let urlString = "\(baseUrlString)\(USTopHeadline)&apikey=\(APIKey.key)"
        guard let url = URL(string: urlString) else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard error == nil, let data = data else {
                completion(nil)
                return
            }
            
            let newsEnvelope = try? JSONDecoder().decode(NewsEnvelope.self, from: data)
            newsEnvelope == nil ? completion(nil) : completion(newsEnvelope!.articles)
        }.resume()
    }

    func getImage (urlString: String, completion: @escaping (Data?) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        if let cachedImage = imageCache.object(forKey: NSString(string: urlString)) {
            completion(cachedImage as Data)
        } else {
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                guard error == nil, let data = data else {
                    completion(nil)
                    return
                }
                self.imageCache.setObject(data as NSData, forKey: NSString(string: urlString))
                completion(data)
            }.resume()
        }
    }
}
