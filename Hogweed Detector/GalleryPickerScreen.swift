//
//  GalleryPickerScreen.swift
//  Hogweed Detector
//
//  Created by Pablo on 14.08.2023.
//

import SwiftUI
import PhotosUI
import Vision

struct GalleryPickerScreen: View {
    @StateObject private var handler = ExampleVisionHandler()
    @State private var selectedItem: PhotosPickerItem?
    @State private var showImageOptions = false
    @State private var selectedSourceType: UIImagePickerController.SourceType?
    @State private var showCamera = false
    @State private var selectedImage = UIImage(named: "btt4")!
    @State private var geometrySize = CGSize(width: 428, height: 300)
    
    func loadImage() {
        handler.clearResults()
        handler.scan(selectedImage.cgImage)
    }
    
    var body: some View {
        VStack {
            Slider(value: $handler.confidence, in: 0...99, step: 1, onEditingChanged: { editing in
                if !editing {
                    handler.scan(selectedImage.cgImage)
                }
            })
            .padding()
            
            Text("Confidence: \(Int(handler.confidence))")
                .padding()
            
            Button("Take a picture or select from gallery") {
                selectedSourceType = nil // Reset the source type when the button is clicked
                showCamera = true
            }
            .actionSheet(isPresented: $showCamera) {
                ActionSheet(title: Text("Select Source"), buttons: [
                    .default(Text("Camera"), action: {
                        selectedSourceType = .camera
                    }),
                    .default(Text("Gallery"), action: {
                        selectedSourceType = .photoLibrary
                    }),
                    .cancel()
                ])
            }
            .sheet(isPresented: Binding<Bool>(get: { selectedSourceType != nil }, set: { _ in selectedSourceType = nil })) {
                if let sourceType = selectedSourceType {
                    ImagePicker(selectedImage: $selectedImage, sourceType: sourceType)
                        .onDisappear(perform: loadImage)
                }
            }
            
            Image(uiImage: selectedImage)
                .resizable()
                .scaledToFit()
                .overlay {
                    GeometryReader { geometry in
                        ZStack {
                            ForEach(handler.results, id: \.uuid) { object in
                                let rect = handler.deNormalize(object.boundingBox, geometry)
                                let label = object.labels.first?.identifier ?? ""
                                let confidence = object.labels.first?.confidence ?? 0.0
                                
                                Rectangle()
                                    .stroke(lineWidth: 2)
                                    .foregroundColor(handler.labelColorMapping[label]) // Set the rectangle color based on label
                                    .frame(width: rect.width, height: rect.height)
                                    .rotationEffect(.degrees(180), anchor: .center) // Rotate the rectangle
                                    .position(x: rect.midX, y: geometry.size.height - rect.midY) // Place the rotated rectangle correctly
                                
                                
                                // Calculate the position for the text label (non-rotated)
                                let textPosition = CGPoint(x: rect.midX, y: geometry.size.height - rect.midY - rect.height / 2 - 16) // Adjust the vertical offset as needed
                                
                                // Place the text label above the rotated rectangle
                                Text("\(label) - \(confidence)")
                                    .foregroundColor(Color.white)
                                    .font(.caption)
                                    .background(Color.black)
                                    .padding(4)
                                    .position(textPosition)
                            }
                        }
                    }
                }
            

            
            Button("Scan") {
                handler.scan(selectedImage.cgImage)
            }
        }
        .onChange(of: selectedItem) { _ in
            Task {
                if let data = try? await selectedItem?.loadTransferable(type: Data.self) {
                    if let uiImage = UIImage(data: data) {
                        handler.clearResults()
                        selectedImage = uiImage
                        return
                    }
                }
            }
        }
    }
}

struct RectanglesOverlay: View {
    var rectangles: [CGRect]
    
    var body: some View {
        ZStack {
            ForEach(rectangles.indices, id: \.self) { index in
                let rect = rectangles[index]
                Rectangle()
                    .stroke(Color.red, lineWidth: 2)
                    .frame(width: rect.size.width, height: rect.size.height)
                    .position(
                        x: rect.midX,
                        y: rect.midY
                    )
            }
        }
    }
}

class ExampleVisionHandler: ObservableObject {
    var image: CGImage!
    
    private var requests: [VNRequest] = []
    @Published var results: [VNRecognizedObjectObservation] = []
    @Published var confidence: Float = 50.0
    
    let labelColorMapping: [String: Color] = [
        "hogweed_sosnowskyi": .red,
        "Umbelliferae": .blue,
    ]
    
    func scan(_ image: CGImage?) {
        if let image = image {
            self.image = image
            performRequests()
        }
    }
    
    func clearResults() {
        results.removeAll()
    }
    
    private func performRequests() {
        let imageRequestHandler = VNImageRequestHandler(cgImage: self.image)
        do {
            try imageRequestHandler.perform(self.requests)
        } catch {
            print(error)
        }
    }
    
    func deNormalize(_ rect: CGRect, _ geometry: GeometryProxy) -> CGRect {
        return VNImageRectForNormalizedRect(rect, Int(geometry.size.width), Int(geometry.size.height))
    }
    
    @discardableResult
    func setupVision() -> NSError? {
        let error: NSError! = nil
        
        guard let modelURL = Bundle.main.url(forResource: "Hogweed3", withExtension: "mlmodelc") else {
            return NSError(domain: "VisionHandler", code: -1, userInfo: [NSLocalizedDescriptionKey: "Model file is missing"])
        }
        do {
            let visionModel = try VNCoreMLModel(for: MLModel(contentsOf: modelURL))
            let objectRecognition = VNCoreMLRequest(model: visionModel, completionHandler: { (request, error) in
                print("Handling results...")
                guard let results = request.results as? [VNRecognizedObjectObservation] else { print("No results array"); return }
                
                
                //                guard let vnResult = result as? VNRecognizedObjectObservation,
                //                      let label = vnResult.labels.first else {
                //                    continue
                //                }
                //                print("detected \(label.identifier) confidence \(label.confidence)")
                //                if label.confidence > confidenceThreshold {
                //                    recognizedObjects.append(RecognizedObject(bounds: vnResult.boundingBox, label: label.identifier, confidence: label.confidence))
                //                }
                
                
                
                guard results.isEmpty == false else {
                    self.results.removeAll()
                    print("Results array is empty, was handling \(self.requests.count) requests"); return
                    
                }
                
                let filtered = results.filter { $0.labels.first?.confidence ?? 0 >= self.confidence / 100 }
                print("Top results: \(results.first?.labels ?? []) : \(results.first?.confidence ?? 0)")
                self.results = filtered
            })
            objectRecognition.imageCropAndScaleOption = .scaleFit
            self.requests = [objectRecognition]
        } catch let error as NSError {
            print("Model loading went wrong: \(error)")
        }
        
        return error
    }
    
    init() {
        setupVision()
    }
}

struct GalleryPickerScreen_Previews: PreviewProvider {
    static var previews: some View {
        GalleryPickerScreen()
    }
}
