//: Playground - noun: a place where people can play

import Foundation
import Himotoki

/// A generic collection
struct Response<T: Decodable> {
    let objects: [T]
    let lastUpdated: NSDate?
}

//: Models
struct Band {
    enum Status: String {
        case Active = "active"
        case Inactive = "inactive"
    }

    let name: String
    let members: [BandMember]
    let homepageURL: NSURL?
    let status: Status
}

struct BandMember {
    let name: String
    let birthDate: NSDate
}

//: Foundation extensions
extension NSURL: Decodable {
    public static func decode(e: Extractor) throws -> Self {
        let rawValue = try String.decode(e)

        guard let result = self.init(string: rawValue) else {
            throw DecodeError.Custom("Error parsing URL from string")
        }

        return result
    }
}

//: Himotoki Transformers
public let DateTransformer = Transformer<String, NSDate> { dateString throws -> NSDate in
    let dateFormatter = NSDateFormatter()
    dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
    dateFormatter.dateFormat = "yyyy-MM-dd"
    dateFormatter.timeZone = NSTimeZone(abbreviation: "UTC")

    if let date = dateFormatter.dateFromString(dateString) {
        return date
    }

    throw customError("Invalid date string: \(dateString)")
}

public let DateTimeTransformer = Transformer<String, NSDate> { dateString throws -> NSDate in
    let dateFormatter = NSDateFormatter()
    dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ'"
    dateFormatter.timeZone = NSTimeZone(abbreviation: "UTC")

    if let date = dateFormatter.dateFromString(dateString) {
        return date
    }

    throw customError("Invalid datetime string: \(dateString)")
}

//: Decodable implementations for our models

extension Response: Decodable {
    static func decode<T: Decodable>(e: Extractor) throws -> Response<T> {
        return try Response<T>(objects: e <|| "objects",
            lastUpdated: DateTimeTransformer.apply(e <|? "last_updated")
        )
    }
}

extension BandMember: Decodable {
    static func decode(e: Extractor) throws -> BandMember {
        return try BandMember(name: e <| "name",
            birthDate: DateTransformer.apply(e <| "birth_date")
        )
    }
}

extension Band: Decodable {
    static func decode(e: Extractor) throws -> Band {
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
    print(response?.objects.first?.name)
} catch {
    error
}

