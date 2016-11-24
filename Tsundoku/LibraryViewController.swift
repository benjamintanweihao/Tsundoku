import UIKit
import RealmSwift

class LibraryViewController: UITableViewController {
    var barcodeEntry: String?
    let fetcher = AmazonProductFetcher()
    let realm = try! Realm()
    lazy var collection: Results<AmazonBook> = { self.realm.objects(AmazonBook.self) } ()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if barcodeEntry != nil {
            do {
                try fetcher.fetch(isbn: barcodeEntry!) { book in
                    print(book)
                    
                    if (book.title.isEmpty || book.author.isEmpty || book.mediumImageURL.isEmpty) {
                        self.showAlertDialog()
                    } else {
                        try! self.realm.write() {
                            self.realm.add(book)
                            self.tableView.reloadData()
                        }
                    }
                }
            } catch {
                showAlertDialog()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.collection.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")! as! LibraryTableViewCell
        let entry = collection[indexPath.row]
        cell.titleLabel.text = entry.title
        cell.authorLabel.text = entry.author
        cell.bookImage.image = try! UIImage(data: Data(contentsOf: URL(string: entry.mediumImageURL)!))
        
        return cell
    }

    func showAlertDialog() {
        let alert = UIAlertController(title: "Whoops", message: "Had a problem adding your book.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
}
