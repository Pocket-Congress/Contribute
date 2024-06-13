import SwiftUI

@available(macOS 12.0, *)
public class CongressDotGov {
    static let scheme = "https"
    static let host = "api.congress.gov"
    static let version_path = "/v3"
    static let api_key = "29Qv1YrP9bpnYMG9VrRUCYTzU2akRc8Bl1mxPqjL"
    static let decoder = JSONDecoder()
    
    /**
     * Get bills filtered by optional parameters.
     * Parameters congress, billType, and billNumber must be given in order, i.e. If billType is given without congress also being given, and error will be thrown
     */
    public static func getBillsAsync(congress: Int? = nil, billType: String? = nil, billNumber: Int? = nil,
                         fromDateTime: String? = nil, toDateTime: String? = nil, count: Int? = nil
//                         ,onCompletion: @escaping ([Bill]) -> ()
    ) async -> [Bill] {
        
        var bills: [Bill] = []
        var urlComponents = CongressDotGov.buildURL()
        
        // Build URL Path
        urlComponents.path += "/bill"
        if congress != nil {
            urlComponents.path += "/" + String(congress!)
            
            if billType != nil {
                urlComponents.path += "/" + billType!
                
                if billNumber != nil {
                    urlComponents.path += "/" + String(billNumber!)
                }
                
            } else if billNumber != nil {
                print("Can't filter by billNumber without billType.") // Should I throw an error here?
            }
        } else if billType != nil || billNumber != nil {
            print("Can't filter by billType or billNumber without congress.") // Should I throw an error here?
        }
        
        // Add URL Query Items
        if fromDateTime != nil {
            urlComponents.queryItems! += [URLQueryItem(name: "fromDateTime", value: fromDateTime)]
        }
        
        if toDateTime != nil {
            urlComponents.queryItems! += [URLQueryItem(name: "toDateTime", value: toDateTime)]
        }
        
        // TODO If count is higher than 250, we need to do multiple requests
        if count != nil && count! > 0 && count! < 251 {
            urlComponents.queryItems! += [URLQueryItem(name: "limit", value: String(count!))]
        }
        
        print(urlComponents.url!)
        
        do {
            let (data, response) = try await URLSession.shared.data(from: urlComponents.url!)
            let responseData = try CongressDotGov.decoder.decode(BillResponse.self, from: data)
            bills = responseData.bills
            return bills
        } catch {
            CongressDotGov.logJSONError(error: error)
        }
        
        // This was the @escaping version, changed to async/await
//        let task = URLSession.shared.dataTask(with: urlComponents.url!) { data, response, error in
//            if let data = data {
//                do {
//                    let responseData = try CongressDotGov.decoder.decode(BillResponse.self, from: data)
//                    bills = responseData.bills
//                } catch {
//                    CongressDotGov.logJSONError(error: error)
//                }
//            }
//        }
//        
//        task.resume()
        
        return bills
    }
    
    public static func printBills(congress: Int? = nil, billType: String? = nil, billNumber: Int? = nil,
                                fromDateTime: String? = nil, toDateTime: String? = nil, count: Int? = nil) {
        Task {
            let bills = await CongressDotGov.getBillsAsync()
            print(bills)
        }
    }
    
    private static func buildURL() -> URLComponents {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = version_path
        components.queryItems = [
            URLQueryItem(name: "api_key", value: api_key)
        ]
        
        return components
    }
    
    private static func logJSONError(error: Error) {
        print("Failed to decode JSON: \(error.localizedDescription)")
        if let decodingError = error as? DecodingError {
            switch decodingError {
            case .typeMismatch(let type, let context):
                print("Type '\(type)' mismatch:", context.debugDescription)
                print("codingPath:", context.codingPath)
            case .valueNotFound(let type, let context):
                print("Value '\(type)' not found:", context.debugDescription)
                print("codingPath:", context.codingPath)
            case .keyNotFound(let key, let context):
                print("Key '\(key)' not found:", context.debugDescription)
                print("codingPath:", context.codingPath)
            case .dataCorrupted(let context):
                print("Data corrupted:", context.debugDescription)
                print("codingPath:", context.codingPath)
            default:
                print("Decoding error:", error.localizedDescription)
            }
        }
    }
}

public struct BillResponse: Codable {
    let pagination: Pagination
    let request: Request
    let bills: [Bill]
}

public struct Pagination: Codable {
    let count: Int
    let next: String
}

public struct Request: Codable {
    let contentType: String
    let format: String
}

public struct Bill: Codable {
    let congress: Int
    let latestAction: LatestAction
    let number: String
    let originChamber: String
    let originChamberCode: String
    let title: String
    let type: String
    let updateDate: String
    let updateDateIncludingText: String
    let url: String
}

public struct LatestAction: Codable {
    let actionDate: String
    let text: String
}


//public func getBillInfo(billNumber: String) {
//    get_all_bill_info(onCompletion: {
//        bills in
//
//        for bill in bills {
////            if (bill.number == billNumber) {
//                print(bill.updateDate)
////            }
//        }
//    })
//}
