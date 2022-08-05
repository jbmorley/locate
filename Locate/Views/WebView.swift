import SwiftUI
import WebKit

struct WebView: NSViewRepresentable {

    var url: URL

    func makeNSView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateNSView(_ webView: WKWebView, context: Context) {
        webView.stopLoading()
        webView.evaluateJavaScript("document.body.remove()") { (_, _) in
            webView.load(URLRequest(url: url))
        }
    }

}
