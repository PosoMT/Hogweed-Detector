//
//  VisionHandlerVM.swift
//  Hogweed Detector
//
//  Created by Pablo on 21.08.2023.
//

import Foundation
import SwiftUI
import Vision

class VisionHandlerVM: ObservableObject {
    var image: CGImage!
    
    private var requests: [VNRequest] = []
    @Published var results: [VNRecognizedObjectObservation] = []
    @Published var confidence: Float = 75.0
    let labelColorMapping: [String: Color] = [
        "hogweed_sosnowskyi": .red,
        "Umbelliferae": .blue,
    ]
    private let labelNames = ["hogweed_sosnowskyi" : "Борщевик", "Umbelliferae" : "Зонтичное"]
    
    init() {
        setupVision()
    }
    
    func scan(_ image: CGImage?) {
        if let image = image {
            self.image = image
            performRequests()
        }
    }
    
    private func performRequests() {
        let imageRequestHandler = VNImageRequestHandler(cgImage: self.image)
        do {
            try imageRequestHandler.perform(self.requests)
        } catch {
            print(error)
        }
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
                guard let results = request.results as? [VNRecognizedObjectObservation] else { return }
                guard results.isEmpty == false else {
                    self.results.removeAll()
                    print("Results array is empty, was handling \(self.requests.count) requests"); return
                    
                }
                
                let filtered = results.filter { $0.labels.first?.confidence ?? 0 >= self.confidence / 100 }
                self.results = filtered
            })
            objectRecognition.imageCropAndScaleOption = .scaleFit
            self.requests = [objectRecognition]
        } catch let error as NSError {
            print("Model loading went wrong: \(error)")
        }
        
        return error
    }
    
    func clearResults() {
        results.removeAll()
    }
    
    // MARK: ui processing
    
    func getProperLabelName(label: String) -> String {
        return labelNames[label] ?? "Неизвестное значение"
    }
    
    func deNormalize(_ rect: CGRect, _ geometry: GeometryProxy) -> CGRect {
        return VNImageRectForNormalizedRect(rect, Int(geometry.size.width), Int(geometry.size.height))
    }
}
