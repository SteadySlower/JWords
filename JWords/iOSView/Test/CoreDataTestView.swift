//
//  CoreDataTestView.swift
//  JWords
//
//  Created by JW Moon on 2023/05/07.
//

import SwiftUI
import ComposableArchitecture

struct CoreDataTestView: View {
    
    private let cd = CoreDataClient.shared
    
    @State var sets = [StudySet]()
    @State var showModal = false
    
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(sets) { studySet in
                    VStack {
                        Text(studySet.title + " \(studySet.createdAt.onlyDate)")
                        HStack {
                            NavigationLink("📖") { CDTStudyView(set: studySet) }
                            Button("🗑️") { try! cd.updateSet(studySet, closed: true) }
                        }
                    }
                    .padding(10)
                }
            }
        }
        .sheet(isPresented: $showModal) { CDTSetAddingModal() }
        .toolbar { ToolbarItem {
            HStack {
                Button("⏳") { try! sets = cd.fetchSets() }
                Button("+") { showModal = true }
            }
        }}
    }
}

struct CDTSetAddingModal: View {
    
    private let cd = CoreDataClient.shared
    @State var title: String = ""
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            TextField("제목 입력", text: $title)
            Button("저장") { try! cd.insertSet(title: title); dismiss() }
        }
    }
    
}

struct CDTStudyView: View {
    
    private let cd = CoreDataClient.shared
    
    let set: StudySet
    @State var units = [StudyUnit]()
    @State var showModal = false
    
    init(set: StudySet) {
        self.set = set
    }
    
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(units) { unit in
                    VStack {
                        HuriganaText(hurigana: unit.kanjiText ?? "")
                        Text(unit.meaningText ?? "")
                    }
                    .padding(10)
                    .border(.black)
                }
            }
        }
        .sheet(isPresented: $showModal) {
            StudyUnitAddView(store: Store(
                initialState: AddingUnit.State(set: set),
                reducer: AddingUnit())
            )
        }
        .toolbar { ToolbarItem {
            HStack {
                Button("⏳") {  }
                Button("+") { showModal = true }
            }
        }}
    }
    
}


struct CoreDataTestView_Previews: PreviewProvider {
    static var previews: some View {
        CoreDataTestView()
    }
}
