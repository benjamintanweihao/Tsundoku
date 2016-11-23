import XCTest

@testable import Tsundoku
import Alamofire
import CryptoSwift
import SWXMLHash

class TsundokuTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        print("SETUP")
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testGetProductInfoWithEANBarcode() {
        let asyncExpectation = expectation(description: "async")
        
        Alamofire.request("https://httpbin.org/get").responseJSON { response in
            print(response.request)
            print(response.response)
            print(response.data)
            print(response.response)
            
            asyncExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 5) { error in
            XCTAssert(true)
        }
    }
    
    func testHMAC() throws {
        let key = "secret".utf8.map {$0}
        let bytes = "Message".utf8.map {$0}
        let hmac = try HMAC(key: key, variant: .sha256).authenticate(bytes)
        let d = NSData(bytes: hmac, length: hmac.count).base64EncodedString(options: .init(rawValue: 0))
    
        XCTAssert("qnR8UCqJggD55PohusaBNviGoOJ67HC6Btry4qXLVZc=" == d)
    }
    
    func testFetching() throws {
        let asyncExpectation = expectation(description: "async")
        let fetcher = AmazonProductFetcher()
        try fetcher.fetch(isbn: "9781633430112") { book in
            asyncExpectation.fulfill()
            print(book)
        }
        
        waitForExpectations(timeout: 5) { error in
            XCTAssert(true)
        }
    }
}
