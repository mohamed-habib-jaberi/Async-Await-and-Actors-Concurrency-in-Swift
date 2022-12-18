import UIKit

enum NetworkError: Error {
    case badUrl
    case noData
    case decodingError
}

struct Post: Decodable {
    let title: String
}

func getPosts(completion: @escaping (Result<[Post], NetworkError>) -> Void) {
    
    guard let url = URL(string: "https://jsonplaceholder.typicode.com/posts") else {
        completion(.failure(.badUrl))
        return
    }
    
    URLSession.shared.dataTask(with: url) { data, _, error in
        
        guard let data = data, error == nil else {
            completion(.failure(.noData))
            return
        }
        
        let posts = try? JSONDecoder().decode([Post].self, from: data)
        completion(.success(posts ?? []))
        
    }.resume()
    
}

func getPosts() async throws -> [Post] {
    
    return try await withCheckedThrowingContinuation { continuation in
        getPosts { result in
            switch result {
                case .success(let posts):
                    continuation.resume(returning: posts)
                case .failure(let error):
                    continuation.resume(throwing: error)
            }
        }
    }
    
}

async {
    do {
        let posts = try await getPosts()
        print(posts)
    } catch {
        print(error)
    }
}







