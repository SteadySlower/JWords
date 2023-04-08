//
//  SamplePicker.swift
//  JWords
//
//  Created by JW Moon on 2023/03/19.
//

import SwiftUI

struct SamplePicker: View {
    
    private let samples: [Sample]
    @Binding private var selectedID: String?
    
    init(samples: [Sample], selectedID: Binding<String?>) {
        self.samples = samples
        self._selectedID = selectedID
    }
    
    var body: some View {
        picker
            .background {
                cancelButton
                upButton
                downButton
            }
    }
    
}

// MARK: SubViews

extension SamplePicker {
    
    private var picker: some View {
        Picker("", selection: $selectedID) {
            Text(samples.isEmpty ? "검색결과 없음" : "미선택")
                .tag(nil as String?)
            ForEach(samples, id: \.id) { sample in
                Text(sample.description)
                    .tag(sample.id as String?)
            }
        }
    }
    
    private var cancelButton: some View {
        Button {
            selectedID = nil
        } label: {
                
        }
        .keyboardShortcut(.escape, modifiers: [.command])
        .opacity(0)
    }
    
    private var upButton: some View {
        Button {
            sampleUp()
        } label: {
                
        }
        .keyboardShortcut(.upArrow, modifiers: [.command])
        .opacity(0)
    }
    
    private var downButton: some View {
        Button {
            sampleDown()
        } label: {
                
        }
        .keyboardShortcut(.downArrow, modifiers: [.command])
        .opacity(0)
    }
}

// MARK: Methods

extension SamplePicker {
    func sampleUp() {
        guard !samples.isEmpty else { return }
        if let nowIndex = samples.firstIndex(where: { $0.id == selectedID }) {
            let nextIndex = (nowIndex + 1) % samples.count
            selectedID = samples[nextIndex].id
        } else {
            selectedID = samples[samples.count - 1].id
        }
        
    }
    
    func sampleDown() {
        guard !samples.isEmpty else { return }
        if let nowIndex = samples.firstIndex(where: { $0.id == selectedID }) {
            let nextIndex = (nowIndex - 1) >= 0 ? (nowIndex - 1) : (samples.count - 1)
            selectedID = samples[nextIndex].id
        } else {
            selectedID = samples[0].id
        }
    }
}
