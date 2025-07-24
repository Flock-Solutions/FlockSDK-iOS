//
//  IdentifyRequest.swift
//  FlockSDK
//
//  Created by Hoa Nguyen on 2024-10-02.
//

struct IdentifyRequest: Encodable {
    let externalUserId: String
    let email: String
    let name: String
    let customProperties: CustomProperties?
}

public typealias CustomProperties = [String: CustomPropertyValue]

// Codable enum for string | number | boolean | null
public enum CustomPropertyValue: Codable {
    case string(String)
    case int(Int)
    case double(Double)
    case bool(Bool)
    case null

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            self = .null
        } else if let value = try? container.decode(Bool.self) {
            self = .bool(value)
        } else if let value = try? container.decode(Int.self) {
            self = .int(value)
        } else if let value = try? container.decode(Double.self) {
            self = .double(value)
        } else if let value = try? container.decode(String.self) {
            self = .string(value)
        } else {
            throw DecodingError.typeMismatch(CustomPropertyValue.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Value cannot be decoded"))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case let .string(value):
            try container.encode(value)
        case let .int(value):
            try container.encode(value)
        case let .double(value):
            try container.encode(value)
        case let .bool(value):
            try container.encode(value)
        case .null:
            try container.encodeNil()
        }
    }
}
