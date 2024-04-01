//
//  ContentView.swift
//  FullScanner
//
//  Created by Ammar Ahmed on 22/09/1445 AH.
//

import SwiftUI
import VisionKit


struct ContentView: View {
    @EnvironmentObject var vm:AppViewModel
    
    private var textContentType:[(title:String,textContentType:DataScannerViewController.TextContentType?)] = [
        ("All", .none),
        ("URL", .URL),
        ("Phone",.telephoneNumber),
        ("Email", .emailAddress),
        ("Address", .fullStreetAddress),
    ]
    
    var body: some View {
        switch vm.dataScannerAccessStatus{
            
        case .cameraNotAvailable:
            Text("camera not available")
            
        case .cameraAccessNotGranted:
            Text("Camera access not granted")
            
        case .notDetermained:
            Text("not Determained yet")
            
        case.scannerAvailable:
            mainView
            
        case .scannerNotAvailable:
            Text("ScannerNotAvailable")
        }
    }
    
    private var mainView:some View{
        
        DataScanView(recognizedItems: $vm.recognizedItems,
                     recognizedDataTypes: vm.recognizedDataType,
                     recognizedMultipleItem: vm.RecognizesMultipletItem)
        .background(Color.gray.opacity(0.3))
        .ignoresSafeArea()
        .id(vm.dataScannerViewId)
        
        .sheet(isPresented: .constant(true)){
            bottomView
                .background(.ultraThinMaterial)
                .presentationDetents([.medium,.fraction(0.25)])
                .presentationDragIndicator(.visible)
                .interactiveDismissDisabled()
                .onAppear{
                    guard let windowScren = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                          let contener = windowScren.windows.first?.rootViewController?.presentedViewController else{
                        return
                    }
                    contener.view.backgroundColor = .clear
                }
        }
        
        .onChange(of: vm.scanType){ _ in vm.recognizedItems = []}
        .onChange(of: vm.recognizedDataType){ _ in vm.recognizedItems = []}
        .onChange(of: vm.RecognizesMultipletItem){ _ in vm.recognizedItems = []}
        
    }
    
    private var headerView:some View{
        VStack{
            HStack{
                Picker("Scan Type",selection: $vm.scanType){
                    Text("Barcode").tag(ScannerType.barcod)
                    Text("Text").tag(ScannerType.text)
                }.pickerStyle(.segmented)
                
                Toggle("Scan Multiple",isOn: $vm.RecognizesMultipletItem)
            }.padding(.top)
            
            if vm.scanType == .text {
                Picker("Text content type ",selection: $vm.TextTypeContent){
                    ForEach(textContentType,id:\.self.textContentType){option in
                        Text(option.title).tag(option.textContentType)
                    }
                }.pickerStyle(.segmented)
                
            }
            Text(vm.headerText).padding(.top)
        }
        .padding(.horizontal)
    }
    
    private var bottomView:some View {
        VStack{
            headerView
            ScrollView{
                LazyVStack(alignment:.leading,spacing: 16){
                    ForEach(vm.recognizedItems){item in
                        switch item{
                            
                        case .barcode(let barcode):
                            Text(barcode.payloadStringValue ?? "Unknown Barcode")
                            
                        case .text(let text):
                            Text(text.transcript)
                            
                        @unknown default:
                            Text("Unknown")
                        }
                    }
                    
                }
                .padding()
            }
        }
    }
}

