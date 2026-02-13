import Foundation

enum NetworkError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpStatus(Int)
    case timeout
    case noInternet
    case decoding(Error)
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .httpStatus(let code):
            return "Server error (\(code)). Try again."
        case .timeout:
            return "Request timeout. Check your connection and retry."
        case .noInternet:
            return "No internet connection."
        case .decoding:
            return "Invalid data format (JSON)."
        case .unknown:
            return "Something went wrong. Please retry."
        }
    }
}
