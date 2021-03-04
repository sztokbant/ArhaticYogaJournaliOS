//
//  ViewController.swift
//  ArhaticYogaJournaliOS
//
//  Created by Eduardo Sztokbant on 5/5/17.
//  Copyright © 2017 Eduardo Sztokbant. All rights reserved.
//

import UIKit
import Floaty

class ViewController: UIViewController, UIWebViewDelegate, UIScrollViewDelegate {

    @IBOutlet var webView: UIWebView!
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
        appendAppInfoToUserAgent()
        webView.delegate = self
        webView.scrollView.delegate = self
        webView.loadRequest(URLRequest(url: URL(string: appUrls.getCurrentUrl())!))
    }

    func appendAppInfoToUserAgent() {
        let version: String = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        let userAgent: String =
            UIWebView().stringByEvaluatingJavaScript(from: "navigator.userAgent")! + " ArhaticYogaJournaliOS-" + version
        UserDefaults.standard.register(defaults: ["UserAgent": userAgent])
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest,
                 navigationType: UIWebView.NavigationType) -> Bool {
        if (request.url?.scheme == "tel") {
            // prevents accidental clicks on numbers from being interpreted as "tel:"
            return false
        } else if (request.url?.scheme == "mailto" ||
            ((request.url?.scheme == "http" || request.url?.scheme == "https") && !appUrls.isAllowed(url: (request.url?.absoluteString)!))) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(request.url!, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
            } else {
                UIApplication.shared.openURL(request.url!)
            }
            return false
        } else if (appUrls.isDownloadable(url: (request.url?.absoluteString)!)) {
            initializeDownload(download: request)
            return false
        }

        return true
    }

    // Ref.: https://southernerd.us/blog/tutorial/2017/04/15/Download-Manager-Tutorial.html
    func initializeDownload(download: URLRequest) {
        // TODO: obtain filename from content disposition header, ref.: https://developer.apple.com/documentation/foundation/urlresponse/1415924-suggestedfilename
        let filenamePrefix = "ayj-data"
        let filenameSuffix = "zip"
        let filename = filenamePrefix + "." + filenameSuffix

        let downloadingAlertController : UIAlertController = UIAlertController(title: "", message: "Downloading file " + filename, preferredStyle: UIAlertController.Style.alert)
        self.present(downloadingAlertController, animated: true, completion: nil)

        do {
            let urlToDownload : NSString = (download.url?.absoluteString)! as NSString
            let url : NSURL = NSURL(string: urlToDownload as String)!
            let urlData : NSData = try NSData.init(contentsOf: url as URL)

            if urlData.length > 0 {
                let documentsDirectory : URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                var filePath = documentsDirectory.appendingPathComponent(filenamePrefix).appendingPathExtension(filenameSuffix)

                // Check if file exists, prevent overwrite
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
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint,
                                   targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if (scrollView.contentOffset.y < -100) {
            if (webView.request?.url?.absoluteString == "") {
                webView.loadRequest(URLRequest(url: URL(string: appUrls.getCurrentUrl())!))
            } else {
                webView.reload()
            }
        }
    }

    func webViewDidStartLoad(_ webView: UIWebView) {
        spinner.startAnimating()
    }

    func webViewDidFinishLoad(_ webView: UIWebView) {
        let request: URLRequest = webView.request!
        floatingActionMenuManager.refresh(webView: webView, url: (request.url)!)
        spinner.stopAnimating()
    }

    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        spinner.stopAnimating()

        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle:UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

        self.present(alert, animated: true, completion: nil)
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
