//
//  PostDetailViewController.swift
//  Post Viewer
//
//  Created by yuriy on 3. 2. 26.
//

import UIKit

@MainActor
final class PostDetailViewController: UIViewController {
    private let viewModel: PostDetailViewModel
    private let imageLoader: ImageLoaderProtocol

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let infoStack = UIStackView()
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let textLabelView = UILabel()
    private let likesLabel = UILabel()
    private let dateLabel = UILabel()
    private let activityIndicator = UIActivityIndicatorView(style: .large)

    init(viewModel: PostDetailViewModel, imageLoader: ImageLoaderProtocol) {
        self.viewModel = viewModel
        self.imageLoader = imageLoader
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Post"

        setupViews()
        bindViewModel()
        viewModel.load()
    }

    private func setupViews() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        contentStack.axis = .vertical
        contentStack.alignment = .fill
        contentStack.spacing = 12
        contentStack.translatesAutoresizingMaskIntoConstraints = false

        infoStack.axis = .vertical
        infoStack.alignment = .fill
        infoStack.spacing = 12
        infoStack.isLayoutMarginsRelativeArrangement = true
        infoStack.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)

        scrollView.addSubview(contentStack)

        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.heightAnchor.constraint(equalToConstant: 220).isActive = true
        imageView.backgroundColor = .secondarySystemBackground

        titleLabel.font = UIFont.preferredFont(forTextStyle: .title2)
        titleLabel.numberOfLines = 0

        textLabelView.font = UIFont.preferredFont(forTextStyle: .body)
        textLabelView.numberOfLines = 0

        likesLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        likesLabel.textColor = .secondaryLabel
        dateLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        dateLabel.textColor = .secondaryLabel

        contentStack.addArrangedSubview(imageView)

        let metaStack = UIStackView(arrangedSubviews: [likesLabel, dateLabel])
        metaStack.axis = .horizontal
        metaStack.alignment = .fill
        metaStack.distribution = .equalSpacing

        infoStack.addArrangedSubview(titleLabel)
        infoStack.addArrangedSubview(textLabelView)
        infoStack.addArrangedSubview(metaStack)
        contentStack.addArrangedSubview(infoStack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])

        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func bindViewModel() {
        viewModel.onLoadingChanged = { [weak self] isLoading in
            guard let self = self else { return }
            if isLoading {
                self.activityIndicator.startAnimating()
            } else {
                self.activityIndicator.stopAnimating()
            }
        }

        viewModel.onDetailLoaded = { [weak self] detail in
            guard let self = self else { return }
            self.titleLabel.text = detail.title
            self.textLabelView.text = detail.text

            let date = Date(timeIntervalSince1970: detail.timeshamp)
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            let dateText = formatter.string(from: date)

            self.likesLabel.text = "❤️ \(detail.likesCount)"
            self.dateLabel.text = dateText

            if let url = detail.postImage {
                self.imageLoader.loadImage(from: url) { [weak self] image in
                    self?.imageView.image = image
                }
            } else {
                self.imageView.image = nil
            }
        }

        viewModel.onError = { [weak self] message in
            guard let self = self else { return }
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}

