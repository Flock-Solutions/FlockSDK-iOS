//
//  WebViewController.swift
//  FlockSDK
//
//  Created by Hoa Nguyen on 2024-10-03.
//

import WebKit

@available(iOS 13.0, *)
class WebViewController: UIViewController, WKNavigationDelegate, WKScriptMessageHandler {
  private var webView: WKWebView!
  private let url: URL
  private let backgroundColorHex: String?

  var onClose: (() -> Void)?
  var onSuccess: (() -> Void)?
  var onInvalid: (() -> Void)?

  init(
    url: URL,
    backgroundColorHex: String? = nil,
    onClose: (() -> Void)? = nil,
    onSuccess: (() -> Void)? = nil,
    onInvalid: (() -> Void)? = nil
  ) {
    self.url = url
    self.backgroundColorHex = backgroundColorHex
    self.onClose = onClose
    self.onSuccess = onSuccess
    self.onInvalid = onInvalid
    super.init(nibName: nil, bundle: nil)
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    setupWebView()
  }

  private func setupWebView() {
    let configuration = WKWebViewConfiguration()
    configuration.userContentController.add(self, name: "ReactNativeWebView")

    let userScript = WKUserScript(source: """
      window.ReactNativeWebView = {
        postMessage: function(message) {
          window.webkit.messageHandlers.ReactNativeWebView.postMessage(message);
        }
      };
    """, injectionTime: .atDocumentStart, forMainFrameOnly: false)

    configuration.userContentController.addUserScript(userScript)

    let preferences = WKWebpagePreferences()
    preferences.allowsContentJavaScript = true
    configuration.defaultWebpagePreferences = preferences

    webView = WKWebView(frame: view.bounds, configuration: configuration)
    webView.load(URLRequest(url: url))
    webView.frame = view.bounds
    webView.navigationDelegate = self
    webView.allowsBackForwardNavigationGestures = false
    webView.translatesAutoresizingMaskIntoConstraints = false
    if let hex = backgroundColorHex, let color = UIColor(hex: hex) {
      webView.backgroundColor = color
    }
    view.addSubview(webView)

    NSLayoutConstraint.activate([
      webView.topAnchor.constraint(equalTo: view.topAnchor),
      webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])
  }

  func userContentController(_: WKUserContentController, didReceive message: WKScriptMessage) {
    guard message.name == "ReactNativeWebView",
          let body = message.body as? String,
          let data = body.data(using: .utf8),
          let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
          let event = obj["event"] as? String
    else {
      return
    }
    switch event {
    case "close":
      dismiss(animated: true)
      onClose?()
    case "success":
      onSuccess?()
    case "invalid":
      onInvalid?()
    default:
      break
    }
  }

  deinit {
    let webView = self.webView
    Task { @MainActor in
      webView?.configuration.userContentController.removeScriptMessageHandler(forName: "ReactNativeWebView")
    }
  }
}
