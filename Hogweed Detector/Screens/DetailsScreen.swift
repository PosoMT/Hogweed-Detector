//
//  DetailsScreen.swift
//  Hogweed Detector
//
//  Created by Pablo on 21.08.2023.
//

import SwiftUI

struct DetailsScreen: View {
    @State var isExpanded1 = false
    @State var isExpanded2 = false
    @State var isExpanded3 = false
    @State var isExpanded4 = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    ExpandableText(label: "Семена — его страшная сила", isExpanded: $isExpanded1)
                        .onTapGesture {
                            withAnimation {
                                isExpanded1.toggle()
                            }
                        }
                    if isExpanded1 {
                        DetailsRow(messagesList: ["От 5000 до 70000 семян на одном растении", "Разносятся на колесах авто, по воде, ветром по снегу и др", "До 10 лет сохраняют всхожесть"])
                    }
                    
                    ExpandableText(label: "Подавляет другие растения", isExpanded: $isExpanded2)
                        .onTapGesture {
                            withAnimation {
                                isExpanded2.toggle()
                            }
                        }
                    if isExpanded2 {
                        DetailsRow(messagesList: ["Закрывает свет другим растениям, всходит раньше других и быстро растёт", "Химически: семена выделяют вещества, блокирующие прорастание других растений"])
                    }
                    
                    ExpandableText(label: "Один = очень много!", isExpanded: $isExpanded3)
                        .onTapGesture {
                            withAnimation {
                                isExpanded3.toggle()
                            }
                        }
                    if isExpanded3 {
                        DetailsRow(messagesList: ["Нет естественных врагов здесь. Его не едят звери, птицы и насекомые", "Очень плодовит. Одно растение способно дать начало новой популяции, так как способен к самоопылению"])
                    }
                    
                    ExpandableText(label: "Опасен для людей", isExpanded: $isExpanded4)
                        .onTapGesture {
                            withAnimation {
                                isExpanded4.toggle()
                            }
                        }
                    if isExpanded4 {
                        DetailsRow(messagesList: ["Он является аллергеном, а также содержит вещества, резко повышающие чувствительность кожи к ультрафиолету, что приводит к ожогам", "Является сильным аллергеном", "Источает характерный неприятный запах"])
                    }
                    
                    Spacer()
                    
                }
                .navigationBarTitle("Опасность борщевика", displayMode: .inline)
            }
        }
    }
}

struct DetailsScreen_Previews: PreviewProvider {
    static var previews: some View {
        DetailsScreen()
    }
}
