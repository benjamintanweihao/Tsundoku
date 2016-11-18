import UIKit

class LibraryViewController: UITableViewController {
    var barcodeEntry: String?

    // TODO: Remove static once you figure out how to persist data
    static var entries: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("*** RECEIVED BARCODE ***")
        print(barcodeEntry)
        
        if barcodeEntry != nil {
            LibraryViewController.entries.append(barcodeEntry!)
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return LibraryViewController.entries.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")! as UITableViewCell
        cell.textLabel?.text = LibraryViewController.entries[indexPath.row]
        return cell
    }
}
