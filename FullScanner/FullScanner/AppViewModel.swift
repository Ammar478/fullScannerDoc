//
//  AppViewModel.swift
//  FullScanner
//
//  Created by Ammar Ahmed on 22/09/1445 AH.
//

import AVKit
import Foundation
import SwiftUI
import VisionKit

enum ScannerType:String {
    case barcod,text
}

enum DataScannerAccessStatusType{
    
    case notDetermained
    case cameraAccessNotGranted
    case cameraNotAvailable
    case scannerAvailable
    case scannerNotAvailable
}


@MainActor
final class AppViewModel : ObservableObject{
    
    @Published var dataScannerAccessStatus:DataScannerAccessStatusType = .notDetermained
    @Published var recognizedItems:[RecognizedItem] = []
    @Published var scanType:ScannerType = .barcod
    @Published var TextTypeContent:DataScannerViewController.TextContentType?
    @Published var RecognizesMultipletItem = true
    
    var recognizedDataType:DataScannerViewController.RecognizedDataType{
        scanType == .barcod ? .barcode() : .text(textContentType:TextTypeContent)
    }
    
    var headerText:String {
        if recognizedItems.isEmpty{
            return "Scanning \(scanType.rawValue)"
        }else{
            return "recongnized \(recognizedItems.count) item(s)"
        }
    }
    
    var dataScannerViewId:Int{
        var hasher = Hasher()
        hasher.combine(scanType)
        hasher.combine(RecognizesMultipletItem)
        if let TextTypeContent{
            hasher.combine(TextTypeContent)
        }
        return hasher.finalize()
    }
    
    private var isScannerAvailable:Bool {
        DataScannerViewController.isAvailable && DataScannerViewController.isSupported
    }
    
    func requestDataAccessStatus()async{
        
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            dataScannerAccessStatus = .cameraNotAvailable
            return
        }
        
        switch AVCaptureDevice.authorizationStatus(for: .video){
            
        case .authorized:
            dataScannerAccessStatus = isScannerAvailable ? .scannerAvailable : .scannerNotAvailable
            
        case .restricted, .denied:
            dataScannerAccessStatus = .cameraAccessNotGranted
            
        case .notDetermined:
            let granted = await AVCaptureDevice.requestAccess(for: .video)
            if granted{
                dataScannerAccessStatus = isScannerAvailable ? .scannerAvailable : .scannerNotAvailable
            }else{
                dataScannerAccessStatus = .cameraAccessNotGranted
            }
            
        default:break
            
        }
    }
    
}
