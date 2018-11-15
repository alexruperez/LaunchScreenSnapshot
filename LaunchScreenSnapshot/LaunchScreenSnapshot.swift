//
//  LaunchScreenSnapshot.swift
//  LaunchScreenSnapshot
//
//  Created by Alex Rupérez on 19/5/17.
//  Copyright © 2017 alexruperez. All rights reserved.
//

import UIKit

public class LaunchScreenSnapshot {

    /// Presentation/dismiss animation options.
    public struct Animation {
        /// The total duration of the animations, measured in seconds. If you specify a negative value or 0, the changes are made without animating them. Default is 0.
        public var duration: TimeInterval = 0
        /// The amount of time (measured in seconds) to wait before beginning the animations. Specify a value of 0 to begin the animations immediately. Default is 0.
        public var delay: TimeInterval = 0
        /// The damping ratio for the spring animation as it approaches its quiescent state. To smoothly decelerate the animation without oscillation, use a value of 1. Employ a damping ratio closer to zero to increase oscillation. Default is 1.
        public var dampingRatio: CGFloat = 1
        /// The initial spring velocity. For smooth start to the animation, match this value to the view’s velocity as it was prior to attachment. A value of 1 corresponds to the total animation distance traversed in one second. For example, if the total animation distance is 200 points and you want the start of the animation to match a view velocity of 100 pt/s, use a value of 0.5. Default is 0.
        public var velocity: CGFloat = 0
        /// A mask of options indicating how you want to perform the animations. For a list of valid constants, see UIViewAnimationOptions. Default is [].
        public var options: UIView.AnimationOptions = []

        /**
         Initializes a new LaunchScreenSnapshot.Animation with the provided configuration.

         - Parameter duration: The total duration of the animations, measured in seconds. If you specify a negative value or 0, the changes are made without animating them. Default is 0.
         - Parameter delay: The amount of time (measured in seconds) to wait before beginning the animations. Specify a value of 0 to begin the animations immediately. Default is 0.
         - Parameter dampingRatio: The damping ratio for the spring animation as it approaches its quiescent state.
         To smoothly decelerate the animation without oscillation, use a value of 1. Employ a damping ratio closer to zero to increase oscillation. Default is 1.
         - Parameter velocity: The initial spring velocity. For smooth start to the animation, match this value to the view’s velocity as it was prior to attachment.
         A value of 1 corresponds to the total animation distance traversed in one second. For example, if the total animation distance is 200 points and you want the start of the animation to match a view velocity of 100 pt/s, use a value of 0.5. Default is 0.
         - Parameter options: A mask of options indicating how you want to perform the animations. For a list of valid constants, see UIViewAnimationOptions. Default is [].

         - Returns: A LaunchScreenSnapshot.LaunchScreenSnapshot.Animation instance, custom built.
         */
        public init(duration: TimeInterval = 0, delay: TimeInterval = 0, dampingRatio: CGFloat = 1, velocity: CGFloat = 0, options: UIView.AnimationOptions = []) {
            self.duration = duration
            self.delay = delay
            self.dampingRatio = dampingRatio
            self.velocity = velocity
            self.options = options
        }
    }

    /// Protection trigger.
    public enum Trigger {
        /// Protect when app will resign active.
        case willResignActive
        /// Protect when app did enter background.
        case didEnterBackground
    }

    /// Shared LaunchScreenSnapshot instance with default configuration.
    public static let shared = LaunchScreenSnapshot()
    /// UIWindow where your custom snapshot will be added.
    public var window: UIWindow?
    fileprivate let application: UIApplication
    fileprivate var view: UIView?
    fileprivate var trigger = Trigger.willResignActive
    fileprivate var animation = Animation()
    fileprivate var force = false
    private let notificationCenter: NotificationCenter
    private let bundle: Bundle

    /**
     Protects your app snapshot with the provided parameters.

     - Parameter view: Your custom view for your app snapshot, by default is your Info.plist UILaunchStoryboardName or your UILaunchStoryboards -> UIDefaultLaunchStoryboard initial ViewController view.
     - Parameter animation: Presentation/dismiss animation options.
     - Parameter force: Forces the presentation of your app snapshot. Default is false.

     - Returns: Shared LaunchScreenSnapshot instance with default configuration.
     */
    @discardableResult public static func protect(with view: UIView? = nil, trigger: Trigger = .willResignActive, animation: Animation = Animation(), force: Bool = false) -> LaunchScreenSnapshot {
        let launchScreenSnapshot = LaunchScreenSnapshot.shared
        launchScreenSnapshot.protect(with: view, trigger: trigger, animation: animation, force: force)
        return launchScreenSnapshot
    }

    /**
     Unprotects your app snapshot.

     - Returns: Shared LaunchScreenSnapshot instance with default configuration.
     */
    @discardableResult public static func unprotect() -> LaunchScreenSnapshot {
        let launchScreenSnapshot = LaunchScreenSnapshot.shared
        launchScreenSnapshot.unprotect()
        return launchScreenSnapshot
    }

    /**
     Initializes a new LaunchScreenSnapshot with the provided configuration.

     - Parameter application: Your UIApplication. By default is .shared
     - Parameter notificationCenter: Your NotificationCenter. By default is .default
     - Parameter bundle: Your Bundle. By default is .main

     - Returns: A LaunchScreenSnapshot instance, custom built.
     */
    public init(application: UIApplication = .shared, notificationCenter: NotificationCenter = .default, bundle: Bundle = .main) {
        self.application = application
        self.window = application.delegate?.window ?? application.keyWindow ?? application.windows.first
        self.notificationCenter = notificationCenter
        self.bundle = bundle
        notificationCenter.addObserver(self, selector: #selector(applicationWillResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(applicationDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(applicationWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(applicationDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    deinit {
        unprotect()
        notificationCenter.removeObserver(self)
    }

    /**
     Protects your app snapshot with the provided parameters.

     - Parameter view: Your custom view for your app snapshot, by default is your Info.plist UILaunchStoryboardName or your UILaunchStoryboards -> UIDefaultLaunchStoryboard initial ViewController view.
     - Parameter animation: Presentation/dismiss animation options.
     - Parameter force: Forces the presentation of your app snapshot. Default is false.

     - Returns: true if your app snapshot has been protected.
     */
    @discardableResult public func protect(with view: UIView? = nil, trigger: Trigger = .willResignActive, animation: Animation = Animation(), force: Bool = false) -> Bool {
        self.view = view
        if self.view == nil {
            if let launchStoryboardName = bundle.object(forInfoDictionaryKey: "UILaunchStoryboardName") as? String {
                self.view = viewFromStoryboard(name: launchStoryboardName, bundle: bundle)
            } else if let launchStoryboards = bundle.object(forInfoDictionaryKey: "UILaunchStoryboards") as? [AnyHashable: Any], let defaultLaunchStoryboard = launchStoryboards["UIDefaultLaunchStoryboard"] as? String, let definitions = launchStoryboards["UILaunchStoryboardDefinitions"] as? [AnyHashable: Any], let launchStoryboardName = definitions[defaultLaunchStoryboard] as? String {
                self.view = viewFromStoryboard(name: launchStoryboardName, bundle: bundle)
            }
        }
        self.trigger = trigger
        self.animation = animation
        assert(animation.dampingRatio > 0, "LaunchScreenSnapshot: dampingRatio must be greater than 0.")
        self.force = force
        if force {
            addView()
        }
        return self.view == nil
    }

    /// Unprotects your app snapshot.
    public func unprotect() {
        force = false
        removeView { [weak self] in
            self?.view = nil
        }
    }

}

private extension LaunchScreenSnapshot {

    @objc func applicationWillResignActive(_ notification: Notification) {
        if trigger == .willResignActive {
            addView()
        }
    }

    @objc func applicationDidEnterBackground(_ notification: Notification) {
        if trigger == .didEnterBackground {
            addView()
        }
    }

    @objc func applicationWillEnterForeground(_ notification: Notification) {
        removeView()
    }

    @objc func applicationDidBecomeActive(_ notification: Notification) {
        if force {
            addView()
        } else {
            removeView()
        }
    }

    func addView() {
        application.ignoreSnapshotOnNextApplicationLaunch()
        if let view = view {
            window?.addSubview(view)
            window?.bringSubviewToFront(view)
            view.alpha = 1
        }
    }

    func removeView(completion: (() -> Swift.Void)? = nil) {
        guard !force else {
            return
        }
        if let view = view {
            guard animation.duration > 0 else {
                view.alpha = 0
                view.removeFromSuperview()
                completion?()
                return
            }
            UIView.animate(withDuration: animation.duration, delay: animation.delay, usingSpringWithDamping: animation.dampingRatio, initialSpringVelocity: animation.velocity, options: animation.options, animations: {
                view.alpha = 0
            }, completion: { _ in
                view.removeFromSuperview()
                completion?()
            })
        }
    }

    func viewFromStoryboard(name: String, bundle: Bundle? = nil) -> UIView? {
        let storyboard = UIStoryboard(name: name, bundle: bundle)
        let viewController = storyboard.instantiateInitialViewController()
        return viewController?.view
    }

}
