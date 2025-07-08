//
//  WebViewController.swift
//  FlockSDK
//
//  Created by Hoa Nguyen on 2024-10-03.
//

import WebKit

@available(iOS 13.0, *)
public class WebViewController: UIViewController, WKNavigationDelegate, WKScriptMessageHandler {
    private var webView: WKWebView!
    private let url: URL
    private let backgroundColorHex: String?
    private static let messageHandlerName = "FlockWebView"

    var onClose: (() -> Void)?
    var onSuccess: ((WebViewController) -> Void)?
    var onInvalid: ((WebViewController) -> Void)?

    init(
        url: URL,
        backgroundColorHex: String? = nil,
        onClose: (() -> Void)? = nil,
        onSuccess: ((WebViewController) -> Void)? = nil,
        onInvalid: ((WebViewController) -> Void)? = nil
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

    override public func viewDidLoad() {
        super.viewDidLoad()
        setNeedsStatusBarAppearanceUpdate()

        setupWebView()
    }

    override public var prefersStatusBarHidden: Bool {
        true
    }

    public func userContentController(_: WKUserContentController, didReceive message: WKScriptMessage) {
        guard message.name == WebViewController.messageHandlerName,
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
            onSuccess?(self)
        case "invalid":
            onInvalid?(self)
        default:
            break
        }
    }

    public func navigate(placementId: String) {
        sendNavigateCommand(placementId: placementId)
    }

    deinit {
        let webView = self.webView
        Task { @MainActor in
            webView?.configuration.userContentController.removeScriptMessageHandler(forName: WebViewController.messageHandlerName)
        }
    }

    private func setupWebView() {
        let configuration = WKWebViewConfiguration()
        configuration.userContentController.add(self, name: WebViewController.messageHandlerName)

        // Injecting ReactNativeWebView interface to the webpage.
        // This is a hack until our webpage support native webkit interface.
        let userScript = WKUserScript(source: """
          window.ReactNativeWebView = {
            postMessage: function(message) {
              window.webkit.messageHandlers.\(WebViewController.messageHandlerName).postMessage(message);
            }
          };
        """, injectionTime: .atDocumentStart, forMainFrameOnly: false)

        configuration.userContentController.addUserScript(userScript)

        let preferences = WKWebpagePreferences()
        preferences.allowsContentJavaScript = true
        configuration.defaultWebpagePreferences = preferences

        webView = WKWebView(frame: .zero, configuration: configuration)
        webView.load(URLRequest(url: url))
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.scrollView.contentInset = UIEdgeInsets(top: 24, left: 0, bottom: 0, right: 0)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = false
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.isOpaque = false
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

    /**
     Sends a navigate command to the web page with the given placementId.
     - Parameter placementId: The placement ID to navigate to.
     */
    private func sendNavigateCommand(placementId: String) {
        let json: [String: Any] = [
            "command": "navigate",
            "data": ["placementId": placementId]
        ]
        if let data = try? JSONSerialization.data(withJSONObject: json, options: []),
           let jsonString = String(data: data, encoding: .utf8)
        {
            let flockEventName = "flock_client_event"
            let jsScript = """
            window.dispatchEvent(new CustomEvent(\"\(flockEventName)\", { detail: JSON.parse(\"\(jsonString)\") }));
            """
            webView.evaluateJavaScript(jsScript, completionHandler: nil)
        }
    }
}
