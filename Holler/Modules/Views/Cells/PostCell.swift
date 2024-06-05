//
//  TableViewPostCell.swift
//  Holler
//
//  Created by Berke Parıldar on 15.05.2024.
//

import UIKit
import FirebaseStorage

class PostCell: UITableViewCell {
    
    var post: Post!
    var isLiked: Bool = false
    weak var delegate: CellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var profileImage: UIButton = {
        let button = UIButton(type: .custom)
        button.layer.cornerRadius = 20
        button.layer.masksToBounds = true
        button.backgroundColor = .clear
        button.setImage(UIImage(systemName: "heart"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFill
        button.imageView?.layer.cornerRadius = 16
        button.imageView?.layer.masksToBounds = true
        button.addTarget(self, action: #selector(didTapProfileImage), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 16)
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
        label.font = .systemFont(ofSize: 14)
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
    
    private lazy var replyImage :UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "bubble")
        imageView.tintColor = .lightGray
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
        button.tintColor = .red
        button.addTarget(self, action: #selector(didTapLikeButton), for: .touchUpInside)
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
    
    @objc func didTapLikeButton() {
        if isLiked {
            likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
            delegate?.didTapUnlikeButton(postID: post.id)
        } else {
            likeButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            delegate?.didTapLikeButton(postID: post.id)
        }
        
    }
    
    @objc func didTapProfileImage() {
        delegate?.didTapUserProfile(userID: post.userID, user: post.user)
    }
    
    private func setupViews() {
        contentView.addSubview(profileImage)
        contentView.addSubview(nameLabel)
        contentView.addSubview(usernameLabel)
        contentView.addSubview(timeLabel)
        contentView.addSubview(postTextLabel)
        contentView.addSubview(likeCountLabel)
        contentView.addSubview(likeButton)
        contentView.addSubview(replyCountLabel)
        contentView.addSubview(replyImage)
        
        NSLayoutConstraint.activate([
            profileImage.heightAnchor.constraint(equalToConstant: 40),
            profileImage.widthAnchor.constraint(equalToConstant: 40),
            profileImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            profileImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            
            nameLabel.leadingAnchor.constraint(equalTo: profileImage.trailingAnchor, constant: 8),
            nameLabel.topAnchor.constraint(equalTo: profileImage.topAnchor),
            nameLabel.bottomAnchor.constraint(equalTo: postTextLabel.topAnchor, constant: -2),
            
            usernameLabel.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: 6),
            usernameLabel.bottomAnchor.constraint(equalTo: nameLabel.bottomAnchor),
            
            timeLabel.leadingAnchor.constraint(equalTo: usernameLabel.trailingAnchor, constant: 6),
            timeLabel.bottomAnchor.constraint(equalTo: usernameLabel.bottomAnchor),
            
            postTextLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            postTextLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            postTextLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 2),
            
            likeCountLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            likeCountLabel.centerYAnchor.constraint(equalTo: likeButton.centerYAnchor),
            
            likeButton.widthAnchor.constraint(equalToConstant: 16),
            likeButton.heightAnchor.constraint(equalToConstant: 16),
            likeButton.trailingAnchor.constraint(equalTo: likeCountLabel.trailingAnchor, constant: -10),
            likeButton.topAnchor.constraint(equalTo: postTextLabel.bottomAnchor, constant: 8),
            
            replyCountLabel.trailingAnchor.constraint(equalTo: likeButton.leadingAnchor, constant: -16),
            replyCountLabel.centerYAnchor.constraint(equalTo: replyImage.centerYAnchor),
            
            replyImage.widthAnchor.constraint(equalToConstant: 16),
            replyImage.heightAnchor.constraint(equalToConstant: 16),
            replyImage.trailingAnchor.constraint(equalTo: replyCountLabel.trailingAnchor, constant: -10),
            replyImage.topAnchor.constraint(equalTo: postTextLabel.bottomAnchor, constant: 8),
            replyImage.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    func configure(post: Post) {
        self.post = post
        if let user = post.user {
            nameLabel.text = user.name
            usernameLabel.text = "@\(user.username)"
            let currentTime = Date().timeIntervalSince1970
            let postTimeDifference = currentTime - TimeInterval(post.time)
            timeLabel.text = postTimeDifference.formattedTimeString
            postTextLabel.text = post.postText
            replyCountLabel.text = String(post.replies.count)
            likeCountLabel.text = String(post.likes.count)
            self.profileImage.kf.setImage(with: URL(string: user.profileImageURL), for: .normal)
        }
        if post.likes.contains(UserService.shared.currentUser!.uid) {
            likeButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            isLiked = true
        } else {
            likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
            isLiked = false
        }
    }
    
    func disableProfileImageButton() {
        self.profileImage.isUserInteractionEnabled = false
    }
    
    func disableReplies() {
        self.replyImage.isHidden = true
        self.replyCountLabel.isHidden = true
    }
    
    func enableReplies() {
        self.replyImage.isHidden = false
        self.replyCountLabel.isHidden = false
    }
}
