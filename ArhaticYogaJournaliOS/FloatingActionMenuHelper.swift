//
//  FloatingActionMenuHelper.swift
//  ArhaticYogaJournaliOS
//
//  Created by Eduardo Sztokbant on 5/6/17.
//  Copyright © 2017 Eduardo Sztokbant. All rights reserved.
//

import UIKit
import Floaty

class FloatingActionMenuHelper {

    class func hexStringToUIColor(hex: String) -> UIColor {
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

    class func refresh(floaty: Floaty, webView: UIWebView, appUrls: AppUrls, buttonColor: UIColor) {
        floaty.addItem(item: FloatingActionMenuHelper.buildFloatingActionButton(webView: webView,
                                                                                appUrls: appUrls,
                                                                                buttonColor: buttonColor,
                                                                                title: "Log Practice",
                                                                                icon: "ic_launcher.png",
                                                                                path: "practice_executions/multi"))
        floaty.addItem(item: FloatingActionMenuHelper.buildFloatingActionButton(webView: webView,
                                                                                appUrls: appUrls,
                                                                                buttonColor: buttonColor,
                                                                                title: "Log Tithing",
                                                                                icon: "ic_dollar.png",
                                                                                path: "tithings/new"))
        floaty.addItem(item: FloatingActionMenuHelper.buildFloatingActionButton(webView: webView,
                                                                                appUrls: appUrls,
                                                                                buttonColor: buttonColor,
                                                                                title: "Log Service",
                                                                                icon: "ic_service.png",
                                                                                path: "services/new"))
        floaty.addItem(item: FloatingActionMenuHelper.buildFloatingActionButton(webView: webView,
                                                                                appUrls: appUrls,
                                                                                buttonColor: buttonColor,
                                                                                title: "Log Study",
                                                                                icon: "ic_study.png",
                                                                                path: "studies/new"))

        floaty.plusColor = UIColor.white
        floaty.buttonColor = buttonColor

        floaty.animationSpeed = 0.014
    }

    class func buildFloatingActionButton(webView: UIWebView, appUrls: AppUrls, buttonColor: UIColor, title: String, icon: String, path: String) -> FloatyItem {
        let item = FloatyItem()

        item.title = title
        item.icon = UIImage(named: icon)

        item.buttonColor = buttonColor
        item.titleColor = UIColor.white
        item.titleShadowColor = buttonColor

        item.handler = { item in
            webView.loadRequest(URLRequest(url: URL(string: "https://" + appUrls.currentDomain + "/" + path)!))
        }

        return item
    }

}
