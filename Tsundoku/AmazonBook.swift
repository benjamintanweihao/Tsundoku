import Foundation
import RealmSwift

class AmazonBook: Object {
    dynamic var isbn: String = ""
    dynamic var title: String = ""
    dynamic var author: String = ""
    dynamic var smallImageURL: String = ""
    dynamic var mediumImageURL: String = ""
    dynamic var largeImageURL: String = ""
    dynamic var publisher: String = ""
    dynamic var descriptionContent: String = ""
    dynamic var created = NSDate()
    
    override static func primaryKey() -> String? {
        return "isbn"
    }
}
