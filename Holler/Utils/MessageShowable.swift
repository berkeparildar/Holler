//
//  SuccessDialogue.swift
//  Holler
//
//  Created by Berke Parıldar on 13.05.2024.
//

import UIKit

protocol MessageShowable where Self: UIViewController {
    func showMessage(title: String, confirm: @escaping () -> Void)
}

extension MessageShowable {
    func showMessage(title: String, confirm: @escaping () -> Void) {
        ShowMessage.shared.showDialog(title: title, confirm: confirm)
    }
}

class ShowMessage {
    static let shared = ShowMessage()
    private var backgroundView: UIView!
    private var dialogView: UIView!
    private var confirmAction: (() -> Void)?
    private var messageLabel: UILabel!
    
    private var showingConstraint: NSLayoutConstraint!
    private var hidingConstraint: NSLayoutConstraint!
    
    private init() {
        configureViews()
    }
    
    private func configureViews() {
        backgroundView = UIView(frame: UIScreen.main.bounds)
        backgroundView.backgroundColor = .gray.withAlphaComponent(0.2)
        
        dialogView = UIView()
        dialogView.backgroundColor = .black
        dialogView.layer.cornerRadius = 18
        dialogView.translatesAutoresizingMaskIntoConstraints = false
        dialogView.layer.masksToBounds = true
        
        messageLabel = UILabel()
        messageLabel.font = .systemFont(ofSize: 12)
        messageLabel.textColor = .white
        messageLabel.numberOfLines = 0
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let confirmButton = UIButton(type: .system)
        confirmButton.setTitle("Ok!", for: .normal)
        confirmButton.setTitleColor(.white, for: .normal)
        confirmButton.titleLabel?.font = .systemFont(ofSize: 14)
        confirmButton.backgroundColor = .clear
        confirmButton.addTarget(self, action: #selector(handleConfirm), for: .touchUpInside)
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        
        backgroundView.addSubview(dialogView)
        dialogView.addSubview(messageLabel)
        dialogView.addSubview(confirmButton)
        
        showingConstraint = dialogView.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor)
        hidingConstraint = dialogView.topAnchor.constraint(equalTo: backgroundView.bottomAnchor, constant: 320)
        
        NSLayoutConstraint.activate([
            dialogView.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor),
            dialogView.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 20),
            dialogView.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -20),
            hidingConstraint,

            messageLabel.topAnchor.constraint(equalTo: dialogView.topAnchor, constant: 20),
            messageLabel.centerXAnchor.constraint(equalTo: dialogView.centerXAnchor),
        
            confirmButton.heightAnchor.constraint(equalToConstant: 52),
            confirmButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 20),
            confirmButton.bottomAnchor.constraint(equalTo: dialogView.bottomAnchor, constant: -10),
            confirmButton.leadingAnchor.constraint(equalTo: dialogView.leadingAnchor, constant: 10),
            confirmButton.trailingAnchor.constraint(equalTo: dialogView.trailingAnchor, constant: -10),
        ])
    }
    
    @objc private func handleConfirm() {
        dismissDialog(animated: true)
        confirmAction?()
    }
    
    func showDialog(title: String, confirm: @escaping () -> Void) {
        messageLabel.text = title
        confirmAction = confirm
        
        if let window = UIApplication.shared.windows.first(where: \.isKeyWindow) {
            window.addSubview(backgroundView)
            backgroundView.layoutIfNeeded()
        }
        
        hidingConstraint.isActive = false
        showingConstraint.isActive = true
        
        backgroundView.alpha = 0
        UIView.animate(withDuration: 0.3) {
            self.backgroundView.alpha = 1
            self.backgroundView.layoutIfNeeded()
        }
    }
    
    private func dismissDialog(animated: Bool) {
        showingConstraint.isActive = false
        hidingConstraint.isActive = true
        UIView.animate(withDuration: 0.3, animations: {
            self.backgroundView.alpha = 0
            if animated {
                self.backgroundView.layoutIfNeeded()
            }
        }) { _ in
            self.backgroundView.removeFromSuperview()
        }
    }
}
