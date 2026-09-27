import SwiftUI
import WebKit

struct SVGIconView: UIViewRepresentable {
    let svgPath: String

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView(frame: .zero)
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear
        webView.scrollView.isScrollEnabled = false
        webView.isUserInteractionEnabled = false
        webView.loadHTMLString(html, baseURL: nil)
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        webView.loadHTMLString(html, baseURL: nil)
    }

    private var html: String {
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: svgPath)) else {
            return ""
        }

        let encodedSVG = data.base64EncodedString()

        return """
        <html>
          <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <style>
              html, body {
                margin: 0;
                padding: 0;
                width: 100%;
                height: 100%;
                background: transparent;
                overflow: hidden;
              }
              body {
                display: flex;
                align-items: center;
                justify-content: center;
              }
              img {
                display: block;
                max-width: 100%;
                max-height: 100%;
                object-fit: contain;
              }
            </style>
          </head>
          <body><img src="data:image/svg+xml;base64,\(encodedSVG)" /></body>
        </html>
        """
    }
}
