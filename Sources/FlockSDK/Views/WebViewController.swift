//
//  WebViewController.swift
//  FlockSDK
//
//  Created by Hoa Nguyen on 2024-10-03.
//

import UIKit
import WebKit

@available(iOS 13.0, *)
class WebViewController: UIViewController, WKNavigationDelegate {
    private let url: URL
    private var webView: WKWebView?
    private var closeButton: UIButton?
    private var shareButton: UIButton?
    private var progressView: UIProgressView?
    private var progressObservation: NSKeyValueObservation?
    
    init(url: URL) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
        webView = setupWebView()
        closeButton = setupCloseButton()
        progressView = setupProgressView()
        shareButton = setupShareButton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        displayWebView()
        displayCloseButton()
        dislayShareButton()
        displayProgressView()
    }
    
    /*
     WEB VIEW
     */
    private func setupWebView() -> WKWebView {
        let webConfiguration = WKWebViewConfiguration()
        let webView = WKWebView(frame: view.bounds, configuration: webConfiguration)
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.load(URLRequest(url: url))
        
        return webView
    }
    
    private func displayWebView() {
        if let webView = webView {
            view.addSubview(webView)
            NSLayoutConstraint.activate([
                webView.topAnchor.constraint(equalTo: view.topAnchor),
                webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        }
    }
    
    /**
     BUTTONS
     */
    private func setupCloseButton() -> UIButton {
        let closeButton = UIButton(type: .roundedRect)
        closeButton.setTitle("✕", for: .normal)
        closeButton.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        closeButton.setTitleColor(.white, for: .normal)
        closeButton.clipsToBounds = true
        closeButton.layer.cornerRadius = 16
        closeButton.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        closeButton.setTitleColor(.white, for: .normal)
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        
        return closeButton
    }
    
    private func displayCloseButton() {
        if  let closeButton = closeButton {
            view.addSubview(closeButton)
            NSLayoutConstraint.activate([
                closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
                closeButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
                closeButton.widthAnchor.constraint(equalToConstant: 32),
                closeButton.heightAnchor.constraint(equalToConstant: 32)
            ])
        }
    }
    
    private func setupShareButton() -> UIButton {
        let shareButton = UIButton(type: .roundedRect)
        let image = UIImage(named: "share-icon", in: .module, with: nil)
        shareButton.setImage(image, for: .normal)
        shareButton.tintColor = .white
        shareButton.clipsToBounds = true
        shareButton.layer.cornerRadius = 16
        shareButton.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        shareButton.setTitleColor(.white, for: .normal)
        shareButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        shareButton.translatesAutoresizingMaskIntoConstraints = false
        
        return shareButton
    }
    
    private func dislayShareButton() {
        if let shareButton = shareButton {
            view.addSubview(shareButton)
            NSLayoutConstraint.activate([
                shareButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
                shareButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: -16),
                shareButton.widthAnchor.constraint(equalToConstant: 32),
                shareButton.heightAnchor.constraint(equalToConstant: 32)
            ])
        }
    }
    
    /**
     PROGRESS BAR
     */
    private func setupProgressView() -> UIProgressView {
        let progressView = UIProgressView(progressViewStyle: .default)
        progressView.translatesAutoresizingMaskIntoConstraints = false
    
        return progressView
    }
    
    private func displayProgressView() {
        if let progressView = progressView {
            view.addSubview(progressView)
            NSLayoutConstraint.activate([
                progressView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            ])
        }
    }
    
    @objc func closeTapped() {
        if let navController = navigationController, navController.viewControllers.count > 1 {
            navController.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    deinit {
        progressObservation?.invalidate()
    }
}
