//
//  Created by Dilshod Zopirov on 9/22/25.
//

import UIKit

public class FeedImageCell: UITableViewCell {
    private(set) public lazy var locationContainer = makeLocationContainerView()
    public let locationLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 2
        return label
    }()
    public let descriptionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 14)
        label.textColor = .label
        return label
    }()
    private(set) public lazy var feedImageContainer = makeFeedImageContainerView()
    public let feedImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    private(set) public lazy var feedImageRetryButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
        return button
    }()
    
    var onRetry: (() -> Void)?
    var onReuse: (() -> Void)?

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        selectionStyle = .none
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        contentView.addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
        ])
        
        stackView.addArrangedSubview(locationContainer)
        stackView.addArrangedSubview(feedImageContainer)
        stackView.addArrangedSubview(descriptionLabel)
    }
    
    private func makeLocationContainerView() -> UIView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.alignment = .center
        
        let iconImageView = UIImageView()
        iconImageView.image = UIImage(systemName: "mappin.and.ellipse")
        iconImageView.tintColor = .systemGray
        iconImageView.setContentHuggingPriority(.required, for: .horizontal)
        
        stackView.addArrangedSubview(iconImageView)
        stackView.addArrangedSubview(locationLabel)
        
        return stackView
    }
    
    private func makeFeedImageContainerView() -> UIView {
        let view = UIView()
        
        view.addSubview(feedImageView)
        feedImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            feedImageView.topAnchor.constraint(equalTo: view.topAnchor),
            feedImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            feedImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            feedImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            feedImageView.heightAnchor.constraint(equalToConstant: 400)
        ])
        view.clipsToBounds = true
        view.layer.cornerRadius = 16
        
        return view
    }
    
    @objc private func retryButtonTapped() {
        onRetry?()
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        
        onReuse?()
    }
}
