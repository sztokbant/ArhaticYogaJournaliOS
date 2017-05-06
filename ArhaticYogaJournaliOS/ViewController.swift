//
//  ViewController.swift
//  ArhaticYogaJournaliOS
//
//  Created by Eduardo Sztokbant on 5/5/17.
//  Copyright © 2017 Eduardo Sztokbant. All rights reserved.
//

import UIKit
import Floaty

class ViewController: UIViewController, UIWebViewDelegate, UIScrollViewDelegate, FloatyDelegate {

    @IBOutlet var webView: UIWebView!
    @IBOutlet var spinner: UIActivityIndicatorView!
    var floaty: Floaty = Floaty()

    let allowedDomains: Array<String> = ["arhaticnet.herokuapp.com",
                                         "ayj-beta.herokuapp.com",
                                         "ayjournal.herokuapp.com",
                                         "arhaticyogajournal.com"]

    let defaultUrl: String = "https://arhaticnet.herokuapp.com"

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        buildFloatingActionMenu()
        buildSpinner()
        buildWebView()
    }

    func buildFloatingActionMenu() {
        floaty.addItem(item: buildFloatingActionButton(title: "Log Practice",
                                                       icon: "ic_launcher.png",
                                                       path: "practice_executions/multi"))
        floaty.addItem(item: buildFloatingActionButton(title: "Log Tithing",
                                                       icon: "ic_dollar.png",
                                                       path: "tithings/new"))
        floaty.addItem(item: buildFloatingActionButton(title: "Log Service",
                                                       icon: "ic_service.png",
                                                       path: "services/new"))
        floaty.addItem(item: buildFloatingActionButton(title: "Log Study",
                                                       icon: "ic_study.png",
                                                       path: "studies/new"))

        floaty.plusColor = UIColor.white
        floaty.buttonColor = hexStringToUIColor(hex: "7B41A9")

        floaty.animationSpeed = 0.014

        floaty.fabDelegate = self
        self.view.addSubview(floaty)
    }

    func buildFloatingActionButton(title: String, icon: String, path: String) -> FloatyItem {
        let item = FloatyItem()

        item.title = title
        item.icon = UIImage(named: icon)

        item.buttonColor = hexStringToUIColor(hex: "7B41A9")
        item.titleColor = UIColor.white
        item.titleShadowColor = hexStringToUIColor(hex: "7B41A9")

        item.handler = { item in
            self.webView.loadRequest(URLRequest(url: URL(string: self.defaultUrl + "/" + path)!))
        }

        return item
    }

    func hexStringToUIColor (hex: String) -> UIColor {
        var cString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        if ((cString.characters.count) != 6) {
            return UIColor.gray
        }

        var rgbValue: UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }

    func buildSpinner() {
        spinner.hidesWhenStopped = true
        spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        spinner.color = UIColor.lightGray
    }

    func buildWebView() {
        appendAppInfoToUserAgent()
        webView.delegate = self
        webView.scrollView.delegate = self
        webView.loadRequest(URLRequest(url: URL(string: defaultUrl)!))
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
                 navigationType: UIWebViewNavigationType) -> Bool {
        if (request.url?.scheme == "tel") {
            // prevents accidental clicks on numbers from being interpreted as "tel:"
            return false
        } else if (request.url?.scheme == "mailto" ||
            ((request.url?.scheme == "http" || request.url?.scheme == "https") && !allowedDomains.contains((request.url?.host!)!))) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(request.url!, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(request.url!)
            }
            return false
        }
        return true
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint,
                                   targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if (scrollView.contentOffset.y < -100) {
            webView.reload()
        }
    }

    func webViewDidStartLoad(_ webView: UIWebView) {
        spinner.startAnimating()
    }

    func webViewDidFinishLoad(_ webView: UIWebView) {
        spinner.stopAnimating()
    }

    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        spinner.stopAnimating()
    }
}
