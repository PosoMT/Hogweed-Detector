//
//  ExpandableText.swift
//  Hogweed Detector
//
//  Created by Pablo on 21.08.2023.
//

import SwiftUI

struct ExpandableText: View {
    var label: String
    @Binding var isExpanded: Bool
    
    var body: some View {
        VStack {
            HStack {
                Text(label)
                    .font(.headline)
                    .padding(.leading, 40)
                Spacer()
                Image(systemName: "rectangle.expand.vertical")
                    .padding(.trailing, 30)
                    .foregroundColor(isExpanded ? .red : .green)
            }
        }
        .onTapGesture {
            isExpanded.toggle()
        }
    }
}

struct ExpandableText_Previews: PreviewProvider {
    static var previews: some View {
        ExpandableText(label: "Label test", isExpanded: .constant(true))
    }
}
