import UIKit

class FormViewController: UIViewController {
    @IBOutlet weak var websiteTextView: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? WebViewController {
            if (websiteTextView.text == "") {
                vc.userWebsite = "https://google.com"
            }
            else {
                vc.userWebsite = websiteTextView.text!
            }
        }
    }
}
