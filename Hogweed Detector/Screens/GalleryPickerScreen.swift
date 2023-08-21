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
    @StateObject private var handler = VisionHandlerVM()
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedSourceType: UIImagePickerController.SourceType?
    @State private var showCamera = false
    @State private var selectedImage = UIImage(named: "btt4")!
    @State private var geometrySize = CGSize(width: 428, height: 300)
    
    func loadImage() {
        handler.clearResults()
//        handler.scan(selectedImage.cgImage)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                
                Spacer()
                
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
                                        .foregroundColor(handler.labelColorMapping[label])
                                        .frame(width: rect.width, height: rect.height)
                                        .rotationEffect(.degrees(180), anchor: .center) // другая система координат
                                        .position(x: rect.midX, y: geometry.size.height - rect.midY)
                                    
                                    let textPosition = CGPoint(x: rect.midX, y: geometry.size.height - rect.midY - rect.height / 2 - 16) // Adjust the vertical offset as needed
                                    Text("\(handler.getProperLabelName(label: label)) - \(Int(confidence * 100))%")
                                        .foregroundColor(Color.white)
                                        .font(.caption)
                                        .background(Color.black)
                                        .padding(4)
                                        .position(textPosition)
                                }
                            }
                        }
                    }
                
                Spacer(minLength: 40)
                
                
                if handler.results.isEmpty {
                    Text("Опасностей не найдено 👍")
                        .foregroundColor(.gray)
                        .padding(.top, 16)
                }
                
                
                Text("Процент совпадения: \(Int(handler.confidence))")
                    .padding(.bottom, 0.0)
                Slider(value: $handler.confidence, in: 0...99, step: 1, onEditingChanged: { editing in
                    if !editing {
                        handler.scan(selectedImage.cgImage)
                    }
                })
                .padding(.horizontal, 70)
                
                HStack(spacing: 16) {
                    Button("Выбрать фото") {
                        selectedSourceType = nil // Reset the source type when the button is clicked
                        showCamera = true
                    }
                    .buttonStyle(NeatButton())
                    .actionSheet(isPresented: $showCamera) {
                        ActionSheet(title: Text("Выберите источник"), buttons: [
                            .default(Text("Сделать снимок"), action: {
                                selectedSourceType = .camera
                            }),
                            .default(Text("Галерея"), action: {
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
                    
                    Button("Сканировать изображение") {
                        handler.scan(selectedImage.cgImage)
                    }
                    .buttonStyle(NeatButton())
                }
                .padding(.bottom, 40)
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
            .navigationBarTitle("Найти на фото", displayMode: .inline)
        }
    }
}

struct GalleryPickerScreen_Previews: PreviewProvider {
    static var previews: some View {
        GalleryPickerScreen()
    }
}
