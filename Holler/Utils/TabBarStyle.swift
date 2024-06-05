//
//  TabBarStyle.swift
//  Holler
//
//  Created by Berke Parıldar on 4.06.2024.
//

import UIKit

final class TabBarStyle {
    static func setStyle() -> UITabBarAppearance {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .black
        appearance.shadowImage = nil
        appearance.shadowColor = nil
        let itemAppearance = UITabBarItemAppearance()
        itemAppearance.normal.iconColor = .gray
        itemAppearance.selected.iconColor = .white
        itemAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.gray]
        itemAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.white] // Change the color for selected state
        appearance.stackedLayoutAppearance = itemAppearance
        return appearance
        
    }
}
