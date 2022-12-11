//
//  MoviesLoader.swift
//  MovieQuiz
//
//  Created by Виктория Щербакова on 21.11.2022.
//

import Foundation

protocol MoviesLoading {
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void)
}

struct MoviesLoader: MoviesLoading {
    private enum MoviesLoaderError: Error {
        case noData, decodeFailed(_ error: Error)
    }

    private let networkClient: NetworkRouting

    init(networkClient: NetworkRouting) {
        self.networkClient = networkClient
    }

    //TODO: Вынести ключ куда-нибудь отдельно
    private var mostPopularMoviesUrl: URL {
        guard let url = URL(string: "https://imdb-api.com/en/API/Top250Movies/k_cmbfw31b") else {
            preconditionFailure("Unable to construct mostPopularMoviesUrl")
        }
        return url
    }

    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void) {
        networkClient.fetch(url: mostPopularMoviesUrl) { results in
            switch results {
            case .success(let success):
                do {
                    let popularMovies = try JSONDecoder().decode(MostPopularMovies.self, from: success)
                    handler(.success(popularMovies))
                } catch {
                    print("Couldn't decode data into")
                    handler(.failure(MoviesLoaderError.decodeFailed(error)))
                    return
                }
            case .failure:
                handler(.failure(MoviesLoaderError.noData))
            }
        }
    }
}
