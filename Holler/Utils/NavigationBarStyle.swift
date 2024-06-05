//
//  NavigationBarStyle.swift
//  Holler
//
//  Created by Berke Parıldar on 5.06.2024.
//

import UIKit

final class NavigationBarStyle {
    static func setStyle() -> UINavigationBarAppearance {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .black
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        UIBarButtonItem.appearance().tintColor = .white
        appearance.shadowImage = nil
        appearance.shadowColor = nil
        return appearance
    }
}
