//: Playground - noun: a place where people can play

import Foundation
import Himotoki

/// A generic collection
struct Response<T: Decodable> {
    let objects: [T]
    let lastUpdated: Date?
}

//: Models
struct Band {
    enum Status: String {
        case Active = "active"
        case Hiatus = "hiatus"
        case Disbanded = "inactive"
    }

    let name: String
    let members: [BandMember]
    let homepageURL: NSURL?
    let status: Status
}

struct BandMember {
    let name: String
    let birthDate: Date
}

//: Foundation extensions
extension NSURL: Decodable {
    public static func decode(_ e: Extractor) throws -> Self {
        let rawValue = try String.decode(e)

        guard let result = self.init(string: rawValue) else {
            throw customError("Error parsing URL from string")
        }

        return result
    }
}

//: Himotoki Transformers
public let DateTransformer = Transformer<String, Date> { dateString throws -> Date in
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    dateFormatter.dateFormat = "yyyy-MM-dd"
    dateFormatter.timeZone = TimeZone(abbreviation: "UTC")

    if let date = dateFormatter.date(from: dateString) {
        return date
    }

    throw customError("Invalid date string: \(dateString)")
}

public let DateTimeTransformer = Transformer<String, Date> { dateString throws -> Date in
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ'"
    dateFormatter.timeZone = TimeZone(abbreviation: "UTC")

    if let date = dateFormatter.date(from: dateString) {
        return date
    }

    throw customError("Invalid datetime string: \(dateString)")
}

//: Decodable implementations for our models

extension Response: Decodable {
    static func decode<T: Decodable>(_ e: Extractor) throws -> Response<T> {
        return try Response<T>(objects: e <|| "objects",
            lastUpdated: DateTimeTransformer.apply(e <|? "last_updated")
        )
    }
}

extension BandMember: Decodable {
    static func decode(_ e: Extractor) throws -> BandMember {
        return try BandMember(name: e <| "name",
            birthDate: DateTransformer.apply(e <| "birth_date")
        )
    }
}

extension Band: Decodable {
    static func decode(_ e: Extractor) throws -> Band {
        return try Band(name: e <| "name",
            members: e <|| "members",
            homepageURL: e <|? "homepage",
            status: e <| "active"
        )
    }
}

// Himotoki provides a protocol extension for RawRepresentable types
extension Band.Status: Decodable {}

//: Decoding
let bandJSON = JSONObjectFromPlaygroundResource("bands", ext: "json")

do {
    let response: Response<Band>? = try Response<Band>.decodeValue(bandJSON)
} catch {
    error
}

