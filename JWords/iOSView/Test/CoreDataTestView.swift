//
//  CoreDataTestView.swift
//  JWords
//
//  Created by JW Moon on 2023/05/07.
//

import SwiftUI

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
                            Button("📖") { }
                            Button("🗑️") { try! cd.updateSet(studySet, closed: true) }
                        }
                    }
                    .padding(10)
                }
            }
        }
        .sheet(isPresented: $showModal) { SetAddingModal() }
        .toolbar { ToolbarItem {
            HStack {
                Button("⏳") { try! sets = cd.fetchSets() }
                Button("+") { showModal = true }
            }
        }}
    }
}

struct SetAddingModal: View {
    
    private let cd = CoreDataClient.shared
    @State var title: String = ""
    
    var body: some View {
        VStack {
            TextField("제목 입력", text: $title)
            Button("저장") { try! cd.insertSet(title: title) }
        }
    }
    
}

struct CoreDataTestView_Previews: PreviewProvider {
    static var previews: some View {
        CoreDataTestView()
    }
}
