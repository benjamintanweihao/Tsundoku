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
                        self.showAlertDialog("Whoops", message: "Had a problem adding your book.")
                    } else {
                        if self.realm.object(ofType: AmazonBook.self, forPrimaryKey: book.isbn) == nil {
                            try! self.realm.write() {
                                self.realm.add(book)
                                self.tableView.reloadData()
                            }
                        } else {
                            self.showAlertDialog("Whoops", message: "Book already exists.")
                        }
                    }
                }
            } catch {
                showAlertDialog("Whoops", message: "Had a problem adding your book.")
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
    
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        
//        self.performSegue(withIdentifier: "showBook", sender: indexPath)
//    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showBook") {
            let controller = segue.destination as! AmazonBookViewController
            controller.book = self.collection[(tableView.indexPathForSelectedRow?.row)!]
        }
    }
    
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            try! self.realm.write() {
                self.realm.delete(collection[indexPath.row])
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }
    
    func showAlertDialog(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
}
