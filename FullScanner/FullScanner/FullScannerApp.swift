//
//  FullScannerApp.swift
//  FullScanner
//
//  Created by Ammar Ahmed on 22/09/1445 AH.
//

import SwiftUI

@main
struct FullScannerApp: App {
    @StateObject private var vm = AppViewModel()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(vm)
                .task {
                    await vm.requestDataAccessStatus()
                }
        }
    }
}
