import Foundation
import Alamofire
import CryptoSwift
import SWXMLHash

class AmazonProductFetcher {
    func fetch(isbn: String, onComplete: @escaping (AmazonBook) -> ()) throws {
        let url = try generateURL(withISBN: isbn)
    
        Alamofire.request(url).response { response in
            let amazonBook = AmazonBook()
            
            let xml = SWXMLHash.parse(response.data!)
            let item = xml["ItemLookupResponse"]["Items"]["Item"][0]
            let smallImage = item["SmallImage"]["URL"].element?.text
            let mediumImage = item["MediumImage"]["URL"].element?.text
            let largeImage = item["LargeImage"]["URL"].element?.text
            
            let itemAttributes = item["ItemAttributes"]
            let author = itemAttributes["Author"].all.first?.element?.text
            let title = itemAttributes["Title"].element?.text
            let publisher = itemAttributes["Publisher"].element?.text
            
            let editorialReview = item["EditorialReviews"]["EditorialReview"]
            let description = editorialReview["Content"].element?.text
                        
            amazonBook.author = author ?? ""
            amazonBook.title = title ?? ""
            amazonBook.smallImageURL = smallImage ?? ""
            amazonBook.mediumImageURL = mediumImage ?? ""
            amazonBook.largeImageURL = largeImage ?? ""
            amazonBook.descriptionContent = description ?? ""
            amazonBook.publisher = publisher ?? ""
            
            onComplete(amazonBook)
        }
    }

    func generateURL(withISBN isbn: String) throws -> String {
        let params = generateParams(withISBN: isbn)
        let signature = try generateSignature(withParams: params)
        
        return "http://webservices.amazon.com/onca/xml?" + params + "&Signature=" +
            signature
                .replacingOccurrences(of: "+", with: "%2B")
                .replacingOccurrences(of: "=", with: "%3D")
                .replacingOccurrences(of: "/", with: "%2F")
    }
    
    func generateParams(withISBN isbn: String) -> String {
        return "AWSAccessKeyId=\(Credentials.awsAccessKeyId)" +
            "&AssociateTag=\(Credentials.associateTag)" +
            "&IdType=ISBN" +
            "&ItemId=\(isbn)" +
            "&Operation=ItemLookup" +
            "&ResponseGroup=Large" +
            "&SearchIndex=Books" +
            "&Service=AWSECommerceService" +
            "&Timestamp=" + generateTimestamp()
    }
    
    func generateTimestamp() -> String {
        return Date()
            .iso8601
            .replacingOccurrences(of: ":", with: "%3A")
    }

    func generateSignature(withParams params: String) throws -> String {
        var stringToSign =
            "GET\nwebservices.amazon.com\n/onca/xml\n" + params
        let key = Credentials.awsSecretKey.utf8.map {$0}
        let bytes = stringToSign.utf8.map {$0}
        let hmac = try HMAC(key: key, variant: .sha256).authenticate(bytes)
        
        return NSData(bytes: hmac, length: hmac.count).base64EncodedString(options: .init(rawValue: 0))
    }
}

extension Date {
    struct Formatter {
        static var iso8601: DateFormatter = {
            let formatter = DateFormatter()
            formatter.calendar = Calendar(identifier: .iso8601)
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssXXXXX"
            return formatter
        }()
    }
    
    var iso8601: String {
        return Formatter.iso8601.string(from: self)
    }
}
