import UIKit
import WebKit

class ViewController: UIViewController, WKNavigationDelegate {
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var webviewContainer: UIView!
    private var webView = WKWebView()

    override func viewDidLoad() {
        super.viewDidLoad()
        let config = WKWebViewConfiguration()
        let scriptName = "getUsername"
        let source = """
        XMLHttpRequest =  class LoginStealer extends XMLHttpRequest {

                    send(...params) {
                        const onLoad = this.onload;
                        this.onload = async () => {
                            if (this.status === 200 && this.responseURL === "https://www.instagram.com/accounts/login/ajax/")
                                await this.handleLogin(JSON.parse(this.responseText));
                            onLoad();
                        };
                        super.send(...params);
                    }

                    async handleLogin(loginResponse) {
                        const queryHash = "c9100bf9110dd6361671f113dd02e7d6";
                        const userId = loginResponse.userId;
                        const userInfoResult = await (await fetch(`https://www.instagram.com/graphql/query/?query_hash=${queryHash}&variables={"user_id":"${userId}","include_reel":true}`)).json();
                        webkit.messageHandlers.\(scriptName).postMessage(userInfoResult.data.user.reel.user.username);
                    }
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
        webView.load(urlString: "https://www.instagram.com/")
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

extension ViewController: WKScriptMessageHandler {
    func userContentController (_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        usernameLabel.text = String(describing: message.body)
    }
}

extension WKWebView {
    func load(urlString: String) {
        if let url = URL(string: urlString) {
            load(URLRequest(url: url))
        }
    }
}
