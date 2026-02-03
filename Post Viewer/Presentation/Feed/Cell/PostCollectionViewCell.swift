//
//  PostCollectionViewCell.swift
//  Post Viewer
//
//  Created by yuriy on 3. 2. 26.
//

import UIKit

import UIKit

@MainActor
final class PostCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "PostCollectionViewCell"

    private let titleLabel = UILabel()
    private let previewLabel = UILabel()
    private let likesLabel = UILabel()
    private let dateLabel = UILabel()
    private let toggleButton = UIButton(type: .system)

    private var currentViewModel: PostCellViewModel?
    private var needsTruncation: Bool = false

    var onToggleExpansion: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        currentViewModel = nil
        needsTruncation = false
        toggleButton.isHidden = true
        onToggleExpansion = nil
    }

    func configure(with viewModel: PostCellViewModel) {
        let wasExpanded = currentViewModel?.isExpanded ?? false
        currentViewModel = viewModel
        
        if titleLabel.text != viewModel.title {
            titleLabel.text = viewModel.title
        }
        
        if previewLabel.text != viewModel.previewText {
            previewLabel.text = viewModel.previewText
        }
        
        if likesLabel.text != viewModel.likesText {
            likesLabel.text = viewModel.likesText
        }
        
        if dateLabel.text != viewModel.dateText {
            dateLabel.text = viewModel.dateText
        }

        // Measure text to determine truncation needs
        // Temporarily set to 0 lines for measurement
        _ = previewLabel.numberOfLines
        previewLabel.numberOfLines = 0
        
        if previewLabel.bounds.width == 0 {
            setNeedsLayout()
            layoutIfNeeded()
        }
        
        let shouldAnimate = wasExpanded != viewModel.isExpanded
        updateTruncationAndButton(shouldAnimate: shouldAnimate)
        
        if wasExpanded != viewModel.isExpanded {
            invalidateIntrinsicContentSize()
        }
    }
    
    private func updateTruncationAndButton(shouldAnimate: Bool = false) {
        guard let viewModel = currentViewModel else { return }
        
        let labelWidth = previewLabel.bounds.width
        
        guard labelWidth > 0 else {
            DispatchQueue.main.async { [weak self] in
                self?.updateTruncationAndButton(shouldAnimate: shouldAnimate)
            }
            return
        }

        let maxLines: CGFloat = 2
        let lineHeight = previewLabel.font.lineHeight
        let maxHeight = lineHeight * maxLines
        let fullSize = previewLabel.sizeThatFits(CGSize(width: labelWidth, height: .greatestFiniteMagnitude))
        let calculatedNeedsTruncation = fullSize.height > maxHeight + (lineHeight * 0.1)
        
        if needsTruncation && !calculatedNeedsTruncation {
            if fullSize.height <= maxHeight {
                needsTruncation = false
            }
        } else {
            needsTruncation = calculatedNeedsTruncation
        }
        
        if needsTruncation {
            previewLabel.numberOfLines = viewModel.isExpanded ? 0 : 2
            
            let title = viewModel.isExpanded ? "Collapse" : "Expand"
            let applyTitle: () -> Void = { [weak self] in
                guard let self = self else { return }
                var config = self.toggleButton.configuration ?? .filled()
                var attributedTitle = AttributedString(title)
                attributedTitle.font = UIFont.preferredFont(forTextStyle: .caption1)
                config.attributedTitle = attributedTitle
                self.toggleButton.configuration = config
            }

            if shouldAnimate {
                UIView.transition(with: toggleButton, duration: 0.6, options: [.showHideTransitionViews, .allowUserInteraction]) {
                    applyTitle()
                }
            } else {
                applyTitle()
            }
            
            toggleButton.isHidden = false
        } else {
            previewLabel.numberOfLines = 0
            toggleButton.isHidden = true
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        if currentViewModel != nil && previewLabel.bounds.width > 0 {
            updateTruncationAndButton()
        }
    }

    private func setupViews() {
        contentView.backgroundColor = .systemBackground

        titleLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        titleLabel.numberOfLines = 0
        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        titleLabel.setContentHuggingPriority(.required, for: .vertical)

        previewLabel.font = UIFont.preferredFont(forTextStyle: .body)
        previewLabel.textColor = .label
        previewLabel.numberOfLines = 0
        previewLabel.lineBreakMode = .byTruncatingTail

        likesLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        likesLabel.textColor = .secondaryLabel
        dateLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        dateLabel.textColor = .secondaryLabel

        var config = UIButton.Configuration.filled()
        
        var attributedTitle = AttributedString("Expand Button")
        attributedTitle.font = UIFont.preferredFont(forTextStyle: .caption1)
        config.attributedTitle = attributedTitle
        config.baseBackgroundColor = UIColor.black.withAlphaComponent(0.7)
        config.baseForegroundColor = .white
        config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
        config.cornerStyle = .medium
        toggleButton.configuration = config
        toggleButton.addTarget(self, action: #selector(toggleButtonTapped), for: .touchUpInside)
        toggleButton.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)

        let metaStack = UIStackView(arrangedSubviews: [likesLabel, dateLabel])
        metaStack.axis = .horizontal
        metaStack.alignment = .fill
        metaStack.distribution = .equalSpacing

        let stack = UIStackView(arrangedSubviews: [previewLabel, toggleButton, metaStack])
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 8

        stack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stack)
        
        NSLayoutConstraint.activate([
            toggleButton.leadingAnchor.constraint(equalTo: stack.leadingAnchor),
            toggleButton.trailingAnchor.constraint(equalTo: stack.trailingAnchor)
        ])

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            stack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }

    @objc
    private func toggleButtonTapped() {
        onToggleExpansion?()
    }
}
