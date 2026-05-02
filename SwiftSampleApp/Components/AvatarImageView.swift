//
//  AvatarImageView.swift
//  SwiftSampleApp
//

import UIKit

final class AvatarImageView: UIView {

    // MARK: - UI Components

    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let initialsLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Properties

    private var imageTask: URLSessionDataTask?

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    // MARK: - Setup

    private func setup() {
        backgroundColor = AppTheme.Color.primary
        addSubview(imageView)
        addSubview(initialsLabel)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),

            initialsLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            initialsLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.width / 2
    }

    // MARK: - Public

    func configure(photoUrl: String?, initials: String) {
        initialsLabel.text = initials
        imageView.image = nil

        guard let urlString = photoUrl, !urlString.isEmpty,
              let url = URL(string: urlString) else {
            imageView.isHidden = true
            initialsLabel.isHidden = false
            return
        }

        imageView.isHidden = false
        initialsLabel.isHidden = true
        imageTask?.cancel()
        imageTask = URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data, let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                self?.imageView.image = image
            }
        }
        imageTask?.resume()
    }

    func configure(user: UserModel) {
        configure(photoUrl: user.photoUrl.isEmpty ? nil : user.photoUrl, initials: user.initials)
    }
}
