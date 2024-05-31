//
//  PostCreateViewController.swift
//  Holler
//
//  Created by Berke Parıldar on 29.05.2024.
//

import UIKit

class PostCreateViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    var viewModel: PostCreateViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    private lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.autocorrectionType = .no
        textField.font = .systemFont(ofSize: 16)
        textField.placeholder = "What's happening?"
        textField.borderStyle = .none
        textField.backgroundColor = .clear
        textField.delegate = self
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var addImageButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "photo"), for: .normal)
        button.addTarget(self, action: #selector(didTapAddImage), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var postButton: UIButton = {
        let button = UIButton(type: .system)
        button.isEnabled = false
        button.setTitle("Post", for: .normal)
        button.addTarget(self, action: #selector(didTapPost), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var selectedImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 8
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isHidden = true
        return imageView
    }()
    
    private lazy var removeImageButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark.circle"), for: .normal)
        button.addTarget(self, action: #selector(didTapRemoveImage), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        return button
    }()
    
    private func setupViews() {
        view.backgroundColor = .black
        view.addSubview(profileImageView)
        view.addSubview(textField)
        view.addSubview(addImageButton)
        view.addSubview(postButton)
        view.addSubview(selectedImageView)
        view.addSubview(removeImageButton)
        profileImageView.kf.setImage(with: URL(string: UserService.shared.currentUser!.profileImageURL))
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            profileImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            profileImageView.widthAnchor.constraint(equalToConstant: 40),
            profileImageView.heightAnchor.constraint(equalToConstant: 40),
            
            textField.topAnchor.constraint(equalTo: profileImageView.topAnchor),
            textField.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 8),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textField.heightAnchor.constraint(equalToConstant: 100),
            
            addImageButton.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 8),
            addImageButton.leadingAnchor.constraint(equalTo: textField.leadingAnchor),
            
            postButton.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 8),
            postButton.trailingAnchor.constraint(equalTo: textField.trailingAnchor),
            
            selectedImageView.topAnchor.constraint(equalTo: addImageButton.bottomAnchor, constant: 8),
            selectedImageView.leadingAnchor.constraint(equalTo: addImageButton.leadingAnchor),
            selectedImageView.trailingAnchor.constraint(equalTo: textField.trailingAnchor),
            selectedImageView.heightAnchor.constraint(equalToConstant: 200),
            
            removeImageButton.topAnchor.constraint(equalTo: selectedImageView.topAnchor, constant: 8),
            removeImageButton.trailingAnchor.constraint(equalTo: selectedImageView.trailingAnchor, constant: -8)
        ])
    }
    
    @objc private func didTapAddImage() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @objc private func textFieldDidChange() {
            validatePostButton()
    }
    
    @objc private func didTapPost() {
        viewModel.createPost(text: textField.text!, imageData: selectedImageView.image?.jpegData(compressionQuality: 0.8)) { [weak self] success, error in
            guard let self = self else { return }
            if let error = error {
                print("There was an error creating post: " + error.localizedDescription)
            }
            if success {
                self.dismiss(animated: true)
            }
        }
    }
    
    @objc private func didTapRemoveImage() {
        selectedImageView.image = nil
        selectedImageView.isHidden = true
        removeImageButton.isHidden = true
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            selectedImageView.image = selectedImage
            selectedImageView.isHidden = false
            removeImageButton.isHidden = false
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    private func validatePostButton() {
        let isTextPresent = !(textField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
        let isImagePresent = selectedImageView.image != nil
        postButton.isEnabled = isTextPresent || isImagePresent
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
            validatePostButton()
        }
        
        func textFieldDidEndEditing(_ textField: UITextField) {
            validatePostButton()
        }
}
