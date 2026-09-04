//
//  CarPlaySceneDelegate.swift
//  StreamCar - CarStream for Apple CarPlay
//

import UIKit
import CarPlay

class CarPlaySceneDelegate: UIResponder, CPTemplateApplicationSceneDelegate {
    
    var interfaceController: CPInterfaceController?
    private var templateManager: CarPlayTemplateManager?
    
    // MARK: - CPTemplateApplicationSceneDelegate
    
    func templateApplicationScene(
        _ templateApplicationScene: CPTemplateApplicationScene,
        didConnect interfaceController: CPInterfaceController
    ) {
        self.interfaceController = interfaceController
        self.templateManager = CarPlayTemplateManager(interfaceController: interfaceController)
        
        print("[StreamCar CarPlay] Head unit connected successfully.")
        
        // Setup initial root CarPlay template
        templateManager?.setupRootTemplate()
        
        // Listen for session configuration changes (e.g. video playback capability)
        let sessionConfig = templateApplicationScene.carConfiguration
        print("[StreamCar CarPlay] Limiter status: \(sessionConfig.navigationOwner)")
    }
    
    func templateApplicationScene(
        _ templateApplicationScene: CPTemplateApplicationScene,
        didDisconnectInterfaceController interfaceController: CPInterfaceController
    ) {
        print("[StreamCar CarPlay] Head unit disconnected.")
        self.interfaceController = nil
        self.templateManager = nil
    }
}
