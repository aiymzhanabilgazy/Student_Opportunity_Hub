import Foundation

protocol OpportunitiesAPIProtocol {
    func fetchJobs(page: Int, query: String?) async throws -> (items: [Opportunity], hasNext: Bool)
}

final class OpportunitiesAPI: OpportunitiesAPIProtocol {

    func fetchJobs(page: Int, query: String?) async throws -> (items: [Opportunity], hasNext: Bool) {

        var components = URLComponents(string: "https://www.arbeitnow.com/api/job-board-api")
        var q: [URLQueryItem] = [URLQueryItem(name: "page", value: "\(page)")]

        if let query, !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            q.append(URLQueryItem(name: "search", value: query))
        }

        components?.queryItems = q

        guard let url = components?.url else { throw NetworkError.invalidURL }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 10

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let http = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            guard (200...299).contains(http.statusCode) else {
                throw NetworkError.httpStatus(http.statusCode)
            }

            let dto = try JSONDecoder().decode(ArbeitnowResponseDTO.self, from: data)
            let hasNext = (dto.links.next != nil)
            let mapped = dto.data.map { $0.toDomainOpportunity() }
            return (mapped, hasNext)

        } catch {
            let ns = error as NSError
            if ns.domain == NSURLErrorDomain {
                switch ns.code {
                case NSURLErrorNotConnectedToInternet:
                    throw NetworkError.noInternet
                case NSURLErrorTimedOut:
                    throw NetworkError.timeout
                default:
                    throw NetworkError.unknown(error)
                }
            }

            if error is DecodingError {
                throw NetworkError.decoding(error)
            }

            throw NetworkError.unknown(error)
        }
    }
}
