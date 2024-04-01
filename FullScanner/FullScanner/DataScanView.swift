//
//  DataScanView.swift
//  FullScanner
//
//  Created by Ammar Ahmed on 22/09/1445 AH.
//

import Foundation
import VisionKit
import Vision
import SwiftUI

struct DataScanView:UIViewControllerRepresentable{
    
    @Binding var recognizedItems:[RecognizedItem]
    
    let recognizedDataTypes :DataScannerViewController.RecognizedDataType
    let recognizedMultipleItem : Bool
    
    func makeUIViewController(context:Context) -> DataScannerViewController {
        let vc = DataScannerViewController(
            recognizedDataTypes: [recognizedDataTypes],
            qualityLevel: .balanced,
            recognizesMultipleItems: recognizedMultipleItem,
            isGuidanceEnabled: true,
            isHighlightingEnabled: true
        )
        return vc
    }
    
    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {
        uiViewController.delegate = context.coordinator
        try? uiViewController.startScanning()
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(recognizedItems: $recognizedItems)
    }
    
    static func dismantleUIViewController(_ uiViewController: DataScannerViewController, coordinator: Coordinator) {
        uiViewController.stopScanning()
    }
    
    class Coordinator:NSObject,DataScannerViewControllerDelegate{
        @Binding var recognizedItems:[RecognizedItem]
        
        init(recognizedItems: Binding<[RecognizedItem]>) {
            self._recognizedItems = recognizedItems
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) {
            print("selected items \(item)")
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, didAdd addedItems: [RecognizedItem], allItems: [RecognizedItem]) {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            recognizedItems.append(contentsOf: addedItems)
            print("added items\(addedItems)")
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, didRemove removedItems: [RecognizedItem], allItems: [RecognizedItem]) {
            self.recognizedItems = removedItems.filter{item in
                !recognizedItems.contains(where: {$0.id == item.id})
            }
            print("removed item \(removedItems)")
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, becameUnavailableWithError error: DataScannerViewController.ScanningUnavailable) {
            print("error \(error)")
        }
    }
    
}
