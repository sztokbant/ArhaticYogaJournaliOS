//
//  ViewController.swift
//  ArhaticYogaJournaliOS
//
//  Created by Eduardo Sztokbant on 5/5/17.
//  Copyright © 2017 Eduardo Sztokbant. All rights reserved.
//

import Floaty
import WebKit

class ViewController: UIViewController, WKNavigationDelegate, UIScrollViewDelegate {

    @IBOutlet var webView: WKWebView!
    @IBOutlet var spinner: UIActivityIndicatorView!

    let appUrls: AppUrls = AppUrls()
    var floatingActionMenuManager: FloatingActionMenuManager!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        floatingActionMenuManager = FloatingActionMenuManager(appUrls: appUrls)
        floatingActionMenuManager.updateCurrentDomain(webView: webView, url: URL(string: appUrls.getCurrentUrl())!)
        buildSpinner()
        buildWebView()
    }

    func buildSpinner() {
        spinner.hidesWhenStopped = true
        spinner.style = UIActivityIndicatorView.Style.whiteLarge
        spinner.color = UIColor.lightGray
    }

    func buildWebView() {
        let appVersion: String = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        webView.customUserAgent = (UIWebView().stringByEvaluatingJavaScript(from: "navigator.userAgent") ?? "") + " ArhaticYogaJournaliOS-" + appVersion

        webView.navigationDelegate = self
        webView.scrollView.delegate = self

        // Enable JavaScript alert dialogs like the one used to delete events
        webView.uiDelegate = self

        // Ensure webview won't cover top/bottom bars
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        webView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        webView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true

        webView.load(URLRequest(url: URL(string: appUrls.getCurrentUrl())!))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if (navigationAction.request.url?.scheme == "tel") {
            // prevents accidental clicks on numbers from being interpreted as "tel:"
            decisionHandler(.cancel)
        } else if (navigationAction.request.url?.scheme == "bitcoin" ||
                   ((navigationAction.request.url?.scheme == "http" || navigationAction.request.url?.scheme == "https") &&
                    !appUrls.isAllowed(url: (navigationAction.request.url?.absoluteString)!)) ||
                   navigationAction.request.url?.scheme == "mailto") {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(navigationAction.request.url!, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
            } else {
                UIApplication.shared.openURL(navigationAction.request.url!)
            }
            decisionHandler(.cancel)
        } else if (appUrls.isDownloadable(url: (navigationAction.request.url?.absoluteString)!)) {
            initializeDownload(urlRequest: navigationAction.request)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }

    // Ref.: https://southernerd.us/blog/tutorial/2017/04/15/Download-Manager-Tutorial.html
    func initializeDownload(urlRequest: URLRequest) {
        // TODO: Obtain filename from content disposition header, ref.: https://developer.apple.com/documentation/foundation/urlresponse/1415924-suggestedfilename
        let filenamePrefix = "ayj-data"
        let filenameSuffix = "zip"
        let filename = filenamePrefix + "." + filenameSuffix

        let downloadAlertController : UIAlertController = UIAlertController(title: "AY Journal Data", message: "The file " + filename + " will be saved to your device's local storage.", preferredStyle: UIAlertController.Style.alert)

        let cancelAction : UIAlertAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler:
        {(alert: UIAlertAction!) in
        })

        let okAction : UIAlertAction = UIAlertAction(title: "Download", style: UIAlertAction.Style.default, handler:
        {(alert: UIAlertAction!) in
            let downloadingAlertController : UIAlertController = UIAlertController(title: "", message: "Downloading file " + filename, preferredStyle: UIAlertController.Style.alert)
            self.present(downloadingAlertController, animated: true, completion: nil)

            do {
                let stringUrl : NSString = (urlRequest.url?.absoluteString)! as NSString
                let url : NSURL = NSURL(string: stringUrl as String)!
                let urlData : NSData = try NSData.init(contentsOf: url as URL)

                if urlData.length > 0 {
                    let documentsDirectory : URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                    var filePath = documentsDirectory.appendingPathComponent(filenamePrefix).appendingPathExtension(filenameSuffix)

                    // Prevent overwrite of existing files
                    var existCount = 0
                    while FileManager.default.fileExists(atPath: filePath.path) {
                        existCount = existCount + 1
                        filePath = documentsDirectory.appendingPathComponent(filenamePrefix + "-" + String(existCount)).appendingPathExtension(filenameSuffix)
                    }

                    urlData.write(to: filePath, atomically: true)
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }

            downloadingAlertController.dismiss(animated: true, completion: nil)
        })

        downloadAlertController.addAction(cancelAction)
        downloadAlertController.addAction(okAction)
        self.present(downloadAlertController, animated: true, completion: nil)
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint,
                                   targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if (scrollView.contentOffset.y < -100) {
            if (webView.url?.absoluteString == "") {
                webView.load(URLRequest(url: URL(string: appUrls.getCurrentUrl())!))
            } else {
                webView.reload()
            }
        }
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        spinner.startAnimating()
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        floatingActionMenuManager.refresh(webView: webView, url: (webView.url)!)
        spinner.stopAnimating()
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        spinner.stopAnimating()

        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle:UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

        self.present(alert, animated: true, completion: nil)
    }
}

// Enable JavaScript alert dialogs like the one used to delete events
// Ref.: https://stackoverflow.com/a/40316507/641293
extension ViewController: WKUIDelegate {
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping () -> Void) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
            completionHandler()
        }))

        present(alertController, animated: true, completion: nil)
    }

    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping (Bool) -> Void) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)

        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
            completionHandler(true)
        }))

        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
            completionHandler(false)
        }))

        present(alertController, animated: true, completion: nil)
    }

    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping (String?) -> Void) {
        let alertController = UIAlertController(title: nil, message: prompt, preferredStyle: .alert)

        alertController.addTextField { (textField) in
            textField.text = defaultText
        }

        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
            if let text = alertController.textFields?.first?.text {
                completionHandler(text)
            } else {
                completionHandler(defaultText)
            }
        }))

        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
            completionHandler(nil)
        }))

        present(alertController, animated: true, completion: nil)
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
