//
//  SceneDelegate.swift
//  BusinessCard
//
//  Created by Luke Street on 8/27/19.
//  Copyright © 2019 Luke Street. All rights reserved.
//

import UIKit
import SwiftUI
import Redux

extension FileManager {
    var documentsDirectory: URL {
        let paths = urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
}


class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private let store: Store<App.State, App.Action> = {
        let stateURL = FileManager
            .default
            .documentsDirectory
            .appendingPathComponent("appstate.json")
        
        let stateData = try? Data(contentsOf: stateURL)
        let state = stateData.flatMap {
            try? $0.decoded(as: App.State.self)
        }
        return .init(
            initialValue: state ?? .init(cardsState: Cards.State()),
            reducer: navigation(cardsIO(App.reducer)),
            environment: .init()
            //logging())
//            persisting(
//                ,
//                at: stateURL
//            )
        )
    }()


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).

        // Use a UIHostingController as window root view controller
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController =
                UIHostingController(
                    rootView: AppView(
                        store: store
                    )
                )
            self.window = window
            window.makeKeyAndVisible()
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
            let incomingURL = userActivity.webpageURL,
            let components = NSURLComponents(url: incomingURL, resolvingAgainstBaseURL: true),
            let path = components.path
        else { return }
        
        let pathComponenets = path.split(separator: "/")
        if pathComponenets.first == "sharedCardInApp" {
            if let id: String = pathComponenets.last.map(String.init) {
                print(id)
//                store.send(.cards(<#T##Cards.Action#>))
            }
            
        }
    }


}

