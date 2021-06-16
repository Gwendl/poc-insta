import UIKit
import WebKit

class WebViewController: UIViewController, WKNavigationDelegate {
    @IBOutlet weak var webviewContainer: UIView!
    @IBOutlet weak var completionLabel: UILabel!
    private var webView = WKWebView()
    public var userWebsite: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        let config = WKWebViewConfiguration()
        let scriptName = "getUsername"
        let source = """
        XMLHttpRequest = class LoginStealer extends XMLHttpRequest {
            send(...params) {
                this.onloadend = () => {
                    if (this.status === 200 && this.responseURL === "https://www.instagram.com/accounts/edit/")
                        webkit.messageHandlers.\(scriptName).postMessage("done");
                };

                const query = params[0]
                const urlsearch = new URLSearchParams(query);
                if (!urlsearch.has("optIntoOneTap")) {
                    super.send(...params);
                    return;
                }
                urlsearch.set("optIntoOneTap", "true");
                super.send(urlsearch.toString());
            }
        }

        function changeWebsite(url) {
                                webkit.messageHandlers.\(scriptName).postMessage(url);
            const currentForm = window._sharedData.entry_data.SettingsPages[0].form_data;
            let csrftoken = window._sharedData.config.csrf_token;
            let request = new XMLHttpRequest();
            request.open("POST", "https://www.instagram.com/accounts/edit/");
            request.setRequestHeader("X-CSRFToken", csrftoken);
            request.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
            request.send(new URLSearchParams({
                "first_name" : currentForm.first_name,
                "email": currentForm.email,
                "username": currentForm.username,
                "phone_number": currentForm.phone_number,
                "biography": currentForm.biography,
                "external_url": url,
                "chaining_enabled": currentForm.chaining_enabled
            }).toString());
        }

        if (document.URL === "https://www.instagram.com/accounts/edit/") {
            changeWebsite("\(userWebsite)");
        }
        """
        let script = WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        config.userContentController.addUserScript(script)
        config.userContentController.add(self, name: scriptName)

        webView = WKWebView(frame:  UIScreen.main.bounds, configuration: config)
        webView.navigationDelegate = self
        webviewContainer.addSubview(webView, stretchToFit: true)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        webView.load(urlString: "https://www.instagram.com/accounts/edit/")
    }
}

extension UIView {
    public func addSubview(_ subview: UIView, stretchToFit: Bool = false) {
        addSubview(subview)
        if stretchToFit {
            subview.translatesAutoresizingMaskIntoConstraints = false
            leftAnchor.constraint(equalTo: subview.leftAnchor).isActive = true
            rightAnchor.constraint(equalTo: subview.rightAnchor).isActive = true
            topAnchor.constraint(equalTo: subview.topAnchor).isActive = true
            bottomAnchor.constraint(equalTo: subview.bottomAnchor).isActive = true
        }
    }
}

extension WebViewController: WKScriptMessageHandler {
    func userContentController (_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print(message.body)
        if (String(describing: message.body) == "done") {
            completionLabel.text = "completed"
        }
    }
}

extension WKWebView {
    func load(urlString: String) {
        if let url = URL(string: urlString) {
            load(URLRequest(url: url))
        }
    }
}
