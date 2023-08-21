//
//  DetailsRow.swift
//  Hogweed Detector
//
//  Created by Pablo on 21.08.2023.
//

import SwiftUI

struct DetailsRow: View {
    let messagesList : [String]
    
    var body: some View {
        HStack {
            ForEach(messagesList, id: \.self) { message in
                Text("\(message)")
                    .foregroundColor(.blue)
                    .font(.subheadline)
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.vertical, 10)
        .background(Color(.systemGray5))
        .cornerRadius(10)
        .padding(.horizontal, 15)
        .padding(.vertical, 5)
    }
}

struct DetailsRow_Previews: PreviewProvider {
    static var previews: some View {
        DetailsRow(messagesList: ["test", "some", "text"])
    }
}
