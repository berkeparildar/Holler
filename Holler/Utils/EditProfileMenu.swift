//
//  EditProfileMenu.swift
//  Holler
//
//  Created by Berke Parıldar on 4.06.2024.
//

import UIKit

struct Action {
    let title: String
    let image: UIImage?
    let handler: () -> Void
}

class MenuViewController: UITableViewController, UIPopoverPresentationControllerDelegate {
    private var actions: [Action] = []

    convenience init(actions: [Action]) {
        self.init(style: .plain)
        self.actions = actions
        modalPresentationStyle = .popover
        preferredContentSize = CGSize(width: 240, height: 40 * actions.count + 4)
        presentationController?.delegate = self
        popoverPresentationController?.permittedArrowDirections = .up
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        tableView.rowHeight = 40
        tableView.separatorInset = .zero
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return actions.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
        let action = actions[indexPath.row]
        cell.textLabel?.text = action.title
        cell.textLabel?.font = .systemFont(ofSize: 14)
        cell.imageView?.image = action.image
        cell.imageView?.tintColor = .white
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let action = actions[indexPath.row]
        action.handler()
    }

    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}
