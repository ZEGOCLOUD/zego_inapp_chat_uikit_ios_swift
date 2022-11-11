//
//  BaseViews.swift
//  ZIMKit
//
//  Created by Kael Ding on 2022/8/26.
//

import Foundation
import UIKit

extension NSObject {
    var classIdentifier: String {
        "\(type(of: self))"
    }
}

// Protocol that provides accessibility features
protocol AccessibilityView {
    // Identifier for view
    var accessibilityViewIdentifier: String { get }

    // This function is called once the view is being added to the view hierarchy
    func setAccessibilityIdentifier()
}

extension AccessibilityView where Self: UIView {
    var accessibilityViewIdentifier: String {
        classIdentifier
    }

    func setAccessibilityIdentifier() {
        accessibilityIdentifier = accessibilityViewIdentifier
    }
}

// Just a protocol to formalize the methods required
public protocol Customizable {
    /// Main point of customization for the view functionality.
    ///
    /// **It's called zero or one time(s) during the view's lifetime.** Calling super implementation is required.
    func setUp()

    /// Main point of customization for the view layout.
    ///
    /// **It's called zero or one time(s) during the view's lifetime.** Calling super is recommended but not required
    /// if you provide a complete layout for all subviews.
    func setUpLayout()

    /// Main point of customizing the way the view updates its content.
    ///
    /// **It's called every time view's content changes.** Calling super is recommended but not required if you update
    /// the content of all subviews of the view.
    func updateContent()
}

public extension Customizable where Self: UIView {
    /// If the view is already in the view hierarchy it calls `updateContent()`, otherwise does nothing.
    func updateContentIfNeeded() {
        if superview != nil {
            updateContent()
        }
    }
}

public extension Customizable where Self: UIViewController {
    /// If the view is already loaded it calls `updateContent()`, otherwise does nothing.
    func updateContentIfNeeded() {
        if isViewLoaded {
            updateContent()
        }
    }
}

/// Base class for overridable views StreamChatUI provides.
/// All conformers will have StreamChatUI appearance settings by default.
open class _View: UIView, Customizable, AccessibilityView {
    // Flag for preventing multiple lifecycle methods calls.
    fileprivate var isInitialized: Bool = false

    override open func didMoveToSuperview() {
        super.didMoveToSuperview()
        guard !isInitialized, superview != nil else { return }

        isInitialized = true

        setAccessibilityIdentifier()
        setUp()
        setUpLayout()
        updateContent()
    }

    open func setUp() { /* default empty implementation */ }
    open func setUpLayout() { setNeedsLayout() }
    open func updateContent() { setNeedsLayout() }

    override open func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        guard #available(iOS 12, *) else { return }
        guard previousTraitCollection?.userInterfaceStyle != traitCollection.userInterfaceStyle else { return }

        TraitCollectionReloadStack.push {
            self.updateContent()
        }
    }

    override open func layoutSubviews() {
        TraitCollectionReloadStack.executePendingUpdates()
        super.layoutSubviews()
    }
}

/// Base class for overridable views StreamChatUI provides.
/// All conformers will have StreamChatUI appearance settings by default.
open class _CollectionViewCell: UICollectionViewCell, Customizable, AccessibilityView {
    // Flag for preventing multiple lifecycle methods calls.
    private var isInitialized: Bool = false

    override open func didMoveToSuperview() {
        super.didMoveToSuperview()
        guard !isInitialized, superview != nil else { return }

        isInitialized = true

        setAccessibilityIdentifier()
        setUp()
        setUpLayout()
        updateContent()
    }

    open func setUp() { /* default empty implementation */ }
    open func setUpLayout() { setNeedsLayout() }
    open func updateContent() { setNeedsLayout() }

    override open func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        guard #available(iOS 12, *) else { return }
        guard previousTraitCollection?.userInterfaceStyle != traitCollection.userInterfaceStyle else { return }

        TraitCollectionReloadStack.push {
            self.updateContent()
        }
    }

    override open func layoutSubviews() {
        TraitCollectionReloadStack.executePendingUpdates()
        super.layoutSubviews()
    }
}

/// Base class for overridable views StreamChatUI provides.
/// All conformers will have StreamChatUI appearance settings by default.
open class _CollectionReusableView: UICollectionReusableView, Customizable, AccessibilityView {
    // Flag for preventing multiple lifecycle methods calls.
    private var isInitialized: Bool = false

    override open func didMoveToSuperview() {
        super.didMoveToSuperview()
        guard !isInitialized, superview != nil else { return }

        isInitialized = true

        setAccessibilityIdentifier()
        setUp()
        setUpLayout()
        updateContent()
    }

    open func setUp() { /* default empty implementation */ }
    open func setUpLayout() { setNeedsLayout() }
    open func updateContent() { setNeedsLayout() }

    override open func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        guard #available(iOS 12, *) else { return }
        guard previousTraitCollection?.userInterfaceStyle != traitCollection.userInterfaceStyle else { return }

        TraitCollectionReloadStack.push {
            self.updateContent()
        }
    }

    override open func layoutSubviews() {
        TraitCollectionReloadStack.executePendingUpdates()
        super.layoutSubviews()
    }
}

/// Base class for overridable views StreamChatUI provides.
/// All conformers will have StreamChatUI appearance settings by default.
open class _Control: UIControl, Customizable, AccessibilityView {
    // Flag for preventing multiple lifecycle methods calls.
    private var isInitialized: Bool = false

    override open func didMoveToSuperview() {
        super.didMoveToSuperview()
        guard !isInitialized, superview != nil else { return }

        isInitialized = true

        setAccessibilityIdentifier()
        setUp()
        setUpLayout()
        updateContent()
    }

    open func setUp() { /* default empty implementation */ }
    open func setUpLayout() { setNeedsLayout() }
    open func updateContent() { setNeedsLayout() }

    override open func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        guard #available(iOS 12, *) else { return }
        guard previousTraitCollection?.userInterfaceStyle != traitCollection.userInterfaceStyle else { return }

        TraitCollectionReloadStack.push {
            self.updateContent()
        }
    }

    override open func layoutSubviews() {
        TraitCollectionReloadStack.executePendingUpdates()
        super.layoutSubviews()
    }
}

/// Base class for overridable views StreamChatUI provides.
/// All conformers will have StreamChatUI appearance settings by default.
open class _Button: UIButton, Customizable, AccessibilityView {
    // Flag for preventing multiple lifecycle methods calls.
    private var isInitialized: Bool = false

    override open func didMoveToSuperview() {
        super.didMoveToSuperview()
        guard !isInitialized, superview != nil else { return }

        isInitialized = true

        setAccessibilityIdentifier()
        setUp()
        setUpLayout()
        updateContent()
    }

    open func setUp() { /* default empty implementation */ }
    open func setUpLayout() { setNeedsLayout() }
    open func updateContent() { setNeedsLayout() }

    override open func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        guard #available(iOS 12, *) else { return }
        guard previousTraitCollection?.userInterfaceStyle != traitCollection.userInterfaceStyle else { return }

        TraitCollectionReloadStack.push {
            self.updateContent()
        }
    }

    override open func layoutSubviews() {
        TraitCollectionReloadStack.executePendingUpdates()
        super.layoutSubviews()
    }
}

/// Base class for overridable views StreamChatUI provides.
/// All conformers will have StreamChatUI appearance settings by default.
open class _NavigationBar: UINavigationBar, Customizable, AccessibilityView {
    // Flag for preventing multiple lifecycle methods calls.
    private var isInitialized: Bool = false

    override open func didMoveToSuperview() {
        super.didMoveToSuperview()
        guard !isInitialized, superview != nil else { return }

        isInitialized = true

        setAccessibilityIdentifier()
        setUp()
        setUpLayout()
        updateContent()
    }

    open func setUp() { /* default empty implementation */ }
    open func setUpLayout() { setNeedsLayout() }
    open func updateContent() { setNeedsLayout() }

    override open func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        guard #available(iOS 12, *) else { return }
        guard previousTraitCollection?.userInterfaceStyle != traitCollection.userInterfaceStyle else { return }

        TraitCollectionReloadStack.push {
            self.updateContent()
        }
    }

    override open func layoutSubviews() {
        TraitCollectionReloadStack.executePendingUpdates()
        super.layoutSubviews()
    }
}

open class _ViewController: UIViewController, Customizable {
    override open var next: UIResponder? {
        // When `self` is being added to the parent controller, the default `next` implementation returns nil
        // unless the `self.view` is added as a subview to `parent.view`. But `self.viewDidLoad` is
        // called before the transition finishes so the subviews are created from `Components.default`.
        // To prevent responder chain from being cutoff during `ViewController` lifecycle we fallback to parent.
        super.next ?? parent
    }

    override open func viewDidLoad() {
        super.viewDidLoad()

        setUp()
        setUpLayout()
        updateContent()
    }

    /**
     A function that will be called on first launch of the `View` it's a function that can be used
     for any initial setup work required by the `View` such as setting delegates or data sources

     `setUp()` is an important function within the ViewController lifecycle
     Its responsibility is to set the delegates and also call `synchronize()`
     this will make sure your local & remote data is in sync.

     - Important: If you override this method without calling `super.setUp()`, it's essential
     to make sure `synchronize()` is called.
     */
    open func setUp() { /* default empty implementation */ }
    open func setUpLayout() { view.setNeedsLayout() }
    open func updateContent() { view.setNeedsLayout() }

    override open func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        guard #available(iOS 12, *) else { return }
        guard previousTraitCollection?.userInterfaceStyle != traitCollection.userInterfaceStyle else { return }

        TraitCollectionReloadStack.push {
            self.updateContent()
        }
    }

    override open func viewWillLayoutSubviews() {
        TraitCollectionReloadStack.executePendingUpdates()
        super.viewWillLayoutSubviews()
    }
}

/// Closure stack, used to reverse order of appearance reloads on trait collection changes
private enum TraitCollectionReloadStack {
    private static var stack: [() -> Void] = []

    static func executePendingUpdates() {
        guard !stack.isEmpty else { return }
        let existingUpdates = stack
        stack.removeAll()
        existingUpdates.reversed().forEach { $0() }
    }

    static func push(_ closure: @escaping () -> Void) {
        stack.append(closure)
    }
}

/// Base class for overridable views StreamChatUI provides.
/// All conformers will have StreamChatUI appearance settings by default.
open class _TableViewCell: UITableViewCell, Customizable, AccessibilityView {
    // Flag for preventing multiple lifecycle methods calls.
    private var isInitialized: Bool = false

    override open func didMoveToSuperview() {
        super.didMoveToSuperview()
        guard !isInitialized, superview != nil else { return }

        isInitialized = true

        setAccessibilityIdentifier()
        setUp()
        setUpLayout()
        updateContent()
    }

    open func setUp() { /* default empty implementation */ }
    open func setUpLayout() { /* default empty implementation */ }
    open func updateContent() { /* default empty implementation */ }

    override open func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        guard #available(iOS 12, *) else { return }
        guard previousTraitCollection?.userInterfaceStyle != traitCollection.userInterfaceStyle else { return }

        TraitCollectionReloadStack.push {
            self.updateContent()
        }
    }

    override open func layoutSubviews() {
        TraitCollectionReloadStack.executePendingUpdates()
        super.layoutSubviews()
    }
}
