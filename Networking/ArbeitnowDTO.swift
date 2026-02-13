import Foundation

struct ArbeitnowResponseDTO: Codable {
    let data: [ArbeitnowJobDTO]
    let links: LinksDTO
    let meta: MetaDTO?

    struct LinksDTO: Codable {
        let first: String?
        let last: String?
        let prev: String?
        let next: String?
    }

    struct MetaDTO: Codable {
        let currentPage: Int?
        enum CodingKeys: String, CodingKey { case currentPage = "current_page" }
    }
}

struct ArbeitnowJobDTO: Codable {
    let slug: String
    let company_name: String
    let title: String
    let description: String
    let remote: Bool?
    let url: String
    let tags: [String]
    let job_types: [String]
    let location: String
    let created_at: Int   // Unix timestamp (seconds)
}

// MARK: - Mapping to your domain model (Opportunity)

extension ArbeitnowJobDTO {

    func toDomainOpportunity() -> Opportunity {

        let createdDate = Date(timeIntervalSince1970: TimeInterval(created_at))

        // API не даёт дедлайн -> бизнес-правило: created + 21 день
        let estimatedDeadline = Calendar.current.date(byAdding: .day, value: 21, to: createdDate) ?? createdDate

        // ✅ 4.7: image from URL (ALWAYS works)
        let image = Self.avatarURL(companyName: company_name)

        return Opportunity(
            id: slug,
            title: title,
            description: Self.stripHTML(description),
            country: location.isEmpty ? "Unknown" : location,
            deadline: estimatedDeadline,
            type: job_types.first ?? (remote == true ? "Remote" : "Job"),
            tags: tags,
            imageURL: image
        )
    }

    // ✅ стабильный URL картинок (генератор аватарок)
    private static func avatarURL(companyName: String) -> String {
        let safe = companyName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "Company"
        return "https://ui-avatars.com/api/?name=\(safe)&background=0b1f3b&color=ffffff&size=512"
    }

    // ✅ удаляем HTML из description
    private static func stripHTML(_ s: String) -> String {
        s.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
            .replacingOccurrences(of: "&nbsp;", with: " ")
            .replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&quot;", with: "\"")
            .replacingOccurrences(of: "&lt;", with: "<")
            .replacingOccurrences(of: "&gt;", with: ">")
    }
}
