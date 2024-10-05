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
    private var webView: WKWebView!
    private let url: URL
    private var closeButton: UIButton!
    private var shareButton: UIButton!
    private var progressView: UIProgressView!
    private var progressObservation: NSKeyValueObservation?
    
    init(url: URL) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupWebView()
        setupCloseButton()
        setupProgressView()
    }
    
    private func setupWebView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: view.bounds, configuration: webConfiguration)
        webView.backgroundColor = .black
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.load(URLRequest(url: url))
        
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupCloseButton() {
        closeButton = UIButton(type: .roundedRect)
        closeButton.setTitle("✕", for: .normal)
        closeButton.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        closeButton.setTitleColor(.white, for: .normal)
        closeButton.clipsToBounds = true
        closeButton.layer.cornerRadius = 16
        closeButton.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        closeButton.setTitleColor(.white, for: .normal)
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(closeButton)
        
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            closeButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            closeButton.widthAnchor.constraint(equalToConstant: 32),
            closeButton.heightAnchor.constraint(equalToConstant: 32)
        ])
    }
    
    private func setupShareButton() {
        shareButton = UIButton(type: .roundedRect)
        
        let shareImg = UIImage(named: "share-icon", in: .module, with: nil)!
        shareButton.setImage(shareImg, for: .normal)
        shareButton.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        shareButton.setTitleColor(.white, for: .normal)
        shareButton.clipsToBounds = true
        shareButton.layer.cornerRadius = 16
        shareButton.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        shareButton.setTitleColor(.white, for: .normal)
        shareButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        shareButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(shareButton)
        
        NSLayoutConstraint.activate([
            shareButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            shareButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: -16),
            shareButton.widthAnchor.constraint(equalToConstant: 32),
            shareButton.heightAnchor.constraint(equalToConstant: 32)
        ])
    }
    
    private func setupProgressView() {
        progressView = UIProgressView(progressViewStyle: .default)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(progressView)
        
        NSLayoutConstraint.activate([
            progressView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
    
    @objc func closeTapped() {
        if let navController = navigationController, navController.viewControllers.count > 1 {
            navController.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    private func updateProgress() {
        progressView.progress = Float(webView.estimatedProgress)
        progressView.isHidden = webView.estimatedProgress == 1
    }
    
    deinit {
        progressObservation?.invalidate()
    }
}
