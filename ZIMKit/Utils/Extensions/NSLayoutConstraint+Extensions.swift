//
//  NSLayoutConstraint+Extensions.swift
//  ZIMKit
//
//  Created by Kael Ding on 2022/8/25.
//

import Foundation

public extension UILayoutPriority {
    /// Having our default priority lower than `.required(1000)` allow user easily
    /// override any default constraints and customize layout
    static let zgRequire = UILayoutPriority(rawValue: 900)
    static let zgAlmostRequire: UILayoutPriority = .zgRequire - 1

    /// The default low priority used for the default layouts. It's higher than the system `defaultLow`.
    static let zgLow = UILayoutPriority.defaultLow + 10

    static let lowest = UILayoutPriority(defaultLow.rawValue / 2.0)
}

public extension NSLayoutConstraint {
    /// Changes the priority of `self` to the provided one.
    /// - Parameter priority: The priority to be applied.
    /// - Returns: `self` with updated `priority`.
    func with(priority: UILayoutPriority) -> NSLayoutConstraint {
        self.priority = priority
        return self
    }

    /// Returns updated `self` with `priority == .zgAlmostRequire`
    var almostRequired: NSLayoutConstraint {
        with(priority: .zgAlmostRequire)
    }
}

public extension NSLayoutAnchor {
    // These methods return an inactive constraint of the form thisAnchor = otherAnchor.
    @objc func pin(equalTo anchor: NSLayoutAnchor<AnchorType>) -> NSLayoutConstraint {
        constraint(equalTo: anchor).with(priority: .zgRequire)
    }

    @objc func pin(greaterThanOrEqualTo anchor: NSLayoutAnchor<AnchorType>) -> NSLayoutConstraint {
        constraint(greaterThanOrEqualTo: anchor).with(priority: .zgRequire)
    }

    @objc func pin(lessThanOrEqualTo anchor: NSLayoutAnchor<AnchorType>) -> NSLayoutConstraint {
        constraint(lessThanOrEqualTo: anchor).with(priority: .zgRequire)
    }

    @objc func pin(equalTo anchor: NSLayoutAnchor<AnchorType>, constant c: CGFloat) -> NSLayoutConstraint {
        constraint(equalTo: anchor, constant: c).with(priority: .zgRequire)
    }

    @objc func pin(greaterThanOrEqualTo anchor: NSLayoutAnchor<AnchorType>, constant c: CGFloat) -> NSLayoutConstraint {
        constraint(greaterThanOrEqualTo: anchor, constant: c).with(priority: .zgRequire)
    }

    @objc func pin(lessThanOrEqualTo anchor: NSLayoutAnchor<AnchorType>, constant c: CGFloat) -> NSLayoutConstraint {
        constraint(lessThanOrEqualTo: anchor, constant: c).with(priority: .zgRequire)
    }
}

// This layout anchor subclass is used for sizes (width & height).

public extension NSLayoutDimension {
    // These methods return an inactive constraint of the form thisVariable = constant.
    @objc func pin(equalToConstant c: CGFloat) -> NSLayoutConstraint {
        constraint(equalToConstant: c).with(priority: .zgRequire)
    }

    @objc func pin(greaterThanOrEqualToConstant c: CGFloat) -> NSLayoutConstraint {
        constraint(greaterThanOrEqualToConstant: c).with(priority: .zgRequire)
    }

    @objc func pin(lessThanOrEqualToConstant c: CGFloat) -> NSLayoutConstraint {
        constraint(lessThanOrEqualToConstant: c).with(priority: .zgRequire)
    }

    // These methods return an inactive constraint of the form thisAnchor = otherAnchor * multiplier.
    @objc func pin(equalTo anchor: NSLayoutDimension, multiplier m: CGFloat) -> NSLayoutConstraint {
        constraint(equalTo: anchor, multiplier: m).with(priority: .zgRequire)
    }

    @objc func pin(greaterThanOrEqualTo anchor: NSLayoutDimension, multiplier m: CGFloat) -> NSLayoutConstraint {
        constraint(greaterThanOrEqualTo: anchor, multiplier: m).with(priority: .zgRequire)
    }

    @objc func pin(lessThanOrEqualTo anchor: NSLayoutDimension, multiplier m: CGFloat) -> NSLayoutConstraint {
        constraint(lessThanOrEqualTo: anchor, multiplier: m).with(priority: .zgRequire)
    }

    // These methods return an inactive constraint of the form thisAnchor = otherAnchor * multiplier + constant.
    @objc func pin(equalTo anchor: NSLayoutDimension, multiplier m: CGFloat, constant c: CGFloat) -> NSLayoutConstraint {
        constraint(equalTo: anchor, multiplier: m, constant: c).with(priority: .zgRequire)
    }

    @objc func pin(
        greaterThanOrEqualTo anchor: NSLayoutDimension,
        multiplier m: CGFloat,
        constant c: CGFloat
    ) -> NSLayoutConstraint {
        constraint(greaterThanOrEqualTo: anchor, multiplier: m, constant: c).with(priority: .zgRequire)
    }

    @objc func pin(lessThanOrEqualTo anchor: NSLayoutDimension, multiplier m: CGFloat, constant c: CGFloat) -> NSLayoutConstraint {
        constraint(lessThanOrEqualTo: anchor, multiplier: m, constant: c).with(priority: .zgRequire)
    }
}

// NSLAYOUTANCHOR_H

public extension NSLayoutXAxisAnchor {
    /* Constraints of the form,
     receiver [= | ≥ | ≤] 'anchor' + 'multiplier' * system space,
     where the value of the system space is determined from information available from the anchors.
     */
    @objc func pin(
        equalToSystemSpacingAfter anchor: NSLayoutXAxisAnchor,
        multiplier: CGFloat = 1
    ) -> NSLayoutConstraint {
        constraint(equalToSystemSpacingAfter: anchor, multiplier: multiplier).with(priority: .zgRequire)
    }

    @objc func pin(
        greaterThanOrEqualToSystemSpacingAfter anchor: NSLayoutXAxisAnchor,
        multiplier: CGFloat = 1
    ) -> NSLayoutConstraint {
        constraint(greaterThanOrEqualToSystemSpacingAfter: anchor, multiplier: multiplier).with(priority: .zgRequire)
    }

    @objc func pin(
        lessThanOrEqualToSystemSpacingAfter anchor: NSLayoutXAxisAnchor,
        multiplier: CGFloat = 1
    ) -> NSLayoutConstraint {
        constraint(lessThanOrEqualToSystemSpacingAfter: anchor, multiplier: multiplier).with(priority: .zgRequire)
    }
}

public extension NSLayoutYAxisAnchor {
    /* Constraints of the form,
     receiver [= | ≥ | ≤] 'anchor' + 'multiplier' * system space,
     where the value of the system space is determined from information available from the anchors.
     The constraint affects how far the receiver will be positioned below 'anchor'.
     If either the receiver or 'anchor' is the firstBaselineAnchor or lastBaselineAnchor of a view with text content
     then the spacing will depend on the fonts involved and will change when those do.
     */
    @objc func pin(
        equalToSystemSpacingBelow anchor: NSLayoutYAxisAnchor,
        multiplier: CGFloat = 1
    ) -> NSLayoutConstraint {
        constraint(equalToSystemSpacingBelow: anchor, multiplier: multiplier).with(priority: .zgRequire)
    }

    @objc func pin(
        greaterThanOrEqualToSystemSpacingBelow anchor: NSLayoutYAxisAnchor,
        multiplier: CGFloat = 1
    ) -> NSLayoutConstraint {
        constraint(greaterThanOrEqualToSystemSpacingBelow: anchor, multiplier: multiplier).with(priority: .zgRequire)
    }

    @objc func pin(
        lessThanOrEqualToSystemSpacingBelow anchor: NSLayoutYAxisAnchor,
        multiplier: CGFloat = 1
    ) -> NSLayoutConstraint {
        constraint(lessThanOrEqualToSystemSpacingBelow: anchor, multiplier: multiplier).with(priority: .zgRequire)
    }
}
