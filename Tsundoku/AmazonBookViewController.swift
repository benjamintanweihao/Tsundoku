import UIKit

class AmazonBookViewController: UIViewController {
    @IBOutlet weak var bookImage: UIImageView!
    @IBOutlet weak var bookDescription: UITextView!

    var book: AmazonBook?

    override func viewDidLoad() {
        if book != nil {
            bookImage.image = try! UIImage(data: Data(contentsOf: URL(string: book!.largeImageURL)!))
            
            do {
                let htmlDescription = try NSAttributedString(data: (book?.descriptionContent.data(using: String.Encoding.unicode, allowLossyConversion: true)!)!, options: [NSDocumentTypeDocumentAttribute : NSHTMLTextDocumentType], documentAttributes: nil)

                bookDescription.attributedText = htmlDescription
            } catch {
                bookDescription.text = ""
            }
        }
    }
}
