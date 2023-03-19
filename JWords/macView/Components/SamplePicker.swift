//
//  SamplePicker.swift
//  JWords
//
//  Created by JW Moon on 2023/03/19.
//

import SwiftUI

struct SamplePicker: View {
    
    private let samples: [Sample]
    private let samplePicked: (Sample?) -> Void
    
    @State var selectedID: String?
    
    var body: some View {
        Picker("", selection: $selectedID) {
            Text(samples.isEmpty ? "검색결과 없음" : "미선택")
                .tag(nil as String?)
            ForEach(samples, id: \.id) { sample in
                Text(sample.description)
                    .tag(sample.id as String?)
            }
        }
        .onChange(of: selectedID) { idPicked($0) }
    }
    
    func idPicked(_ id: String?) {
        let sample = samples.first { $0.id == id }
        samplePicked(sample)
    }
}
