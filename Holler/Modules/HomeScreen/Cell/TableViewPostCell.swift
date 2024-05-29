//
//  TableViewPostCell.swift
//  Holler
//
//  Created by Berke Parıldar on 15.05.2024.
//

import UIKit
import FirebaseStorage

class TableViewPostCell: UITableViewCell {
    
    var hasImage: Bool = false
    var lowestAncor: NSLayoutYAxisAnchor!
    
    private lazy var profileImage: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 14)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var usernameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var postTextLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .white
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var contentImage: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 18
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var replyImage :UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "message")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var replyCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var likeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "heart"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(didLikePost), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var likeCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    private func setupViews() {
        contentView.addSubview(profileImage)
        NSLayoutConstraint.activate([
            profileImage.heightAnchor.constraint(equalToConstant: 32),
            profileImage.widthAnchor.constraint(equalToConstant: 32),
            profileImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            profileImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
        ])
        contentView.addSubview(nameLabel)
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: profileImage.trailingAnchor, constant: 8),
            nameLabel.topAnchor.constraint(equalTo: profileImage.topAnchor),
        ])
        contentView.addSubview(usernameLabel)
        NSLayoutConstraint.activate([
            usernameLabel.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: 8),
            usernameLabel.topAnchor.constraint(equalTo: profileImage.topAnchor)
        ])
        contentView.addSubview(timeLabel)
        NSLayoutConstraint.activate([
            timeLabel.leadingAnchor.constraint(equalTo: usernameLabel.trailingAnchor, constant: 8),
            timeLabel.topAnchor.constraint(equalTo: profileImage.topAnchor)
        ])
        contentView.addSubview(postTextLabel)
        NSLayoutConstraint.activate([
            postTextLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            postTextLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            postTextLabel.topAnchor.constraint(equalTo: profileImage.bottomAnchor, constant: -8)
        ])
        
        if hasImage {
            contentView.addSubview(contentImage)
            NSLayoutConstraint.activate([
                contentImage.topAnchor.constraint(equalTo: postTextLabel.bottomAnchor, constant: 16),
                contentImage.leadingAnchor.constraint(equalTo: postTextLabel.leadingAnchor),
                contentImage.trailingAnchor.constraint(equalTo: postTextLabel.trailingAnchor),
            ])
            lowestAncor = contentImage.bottomAnchor
        }
        else {
            lowestAncor = postTextLabel.bottomAnchor
        }
        
        contentView.addSubview(replyImage)
        NSLayoutConstraint.activate([
            replyImage.widthAnchor.constraint(equalToConstant: 16),
            replyImage.heightAnchor.constraint(equalToConstant: 16),
            replyImage.leadingAnchor.constraint(equalTo: contentView.centerXAnchor, constant: -120),
            replyImage.topAnchor.constraint(equalTo: lowestAncor, constant: 8),
            replyImage.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
        
        contentView.addSubview(replyCountLabel)
        NSLayoutConstraint.activate([
            replyCountLabel.leadingAnchor.constraint(equalTo: replyImage.trailingAnchor, constant: 4),
            replyCountLabel.centerYAnchor.constraint(equalTo: replyImage.centerYAnchor)
        ])
        
        contentView.addSubview(likeButton)
        NSLayoutConstraint.activate([
            likeButton.widthAnchor.constraint(equalToConstant: 16),
            likeButton.heightAnchor.constraint(equalToConstant: 16),
            likeButton.leadingAnchor.constraint(equalTo: contentView.centerXAnchor, constant: 120),
            likeButton.topAnchor.constraint(equalTo: lowestAncor, constant: 8),
        ])
        
        contentView.addSubview(likeCountLabel)
        NSLayoutConstraint.activate([
            likeCountLabel.leadingAnchor.constraint(equalTo: likeButton.trailingAnchor, constant: 4),
            likeCountLabel.centerYAnchor.constraint(equalTo: likeButton.centerYAnchor)
        ])
    }
    
    func configureAsHomePost(with post: HomePagePost) {
        loadImage(from: post.profileImagePath) { url in
            self.profileImage.kf.setImage(with: url)
        }
        nameLabel.text = post.name
        usernameLabel.text = "@\(post.username)"
        timeLabel.text = "Time"
        postTextLabel.text = post.postText
        hasImage = post.hasImage
        if hasImage {
            loadImage(from: post.contentImagePath) { url in
                self.contentImage.kf.setImage(with: url)
            }
        }
        replyCountLabel.text = String(post.replyCount)
        likeCountLabel.text = String(post.likeCount)
        setupViews()
    }
    
    func configureAsProfilePost(profileImage: UIImage, name: String, username: String, with post: ProfilePost) {
        self.profileImage.image = profileImage
        nameLabel.text = name
        usernameLabel.text = username
        timeLabel.text = "Time"
        postTextLabel.text = post.postText
        hasImage = post.hasImage
        if hasImage {
            loadImage(from: post.contentImagePath) { url in
                self.contentImage.kf.setImage(with: url)
            }
        }
        replyCountLabel.text = String(post.replyCount)
        likeCountLabel.text = String(post.likeCount)
        setupViews()
    }
    
    @objc func didLikePost() {
        
    }
    
    func loadImage(from path: String, completion: @escaping (URL?) -> Void) {
            let storage = Storage.storage()
            let storageRef = storage.reference().child(path)
            storageRef.downloadURL { (url, error) in
                if let error = error {
                    print("Error fetching image URL: \(error.localizedDescription)")
                    completion(nil)
                    return
                }
                completion(url)
            }
        }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
