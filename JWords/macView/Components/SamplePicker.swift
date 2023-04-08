//
//  SamplePicker.swift
//  JWords
//
//  Created by JW Moon on 2023/03/19.
//

import SwiftUI

struct SamplePicker: View {
    
    private let samples: [Sample]
    private let selected: Sample?
    private let actionHandler: (Action) -> Void
    
    @State private var selectedID: String?
    
    enum Action {
        case picked(sample: Sample?)
        case cancelled
    }
    
    init(samples: [Sample],
         selected: Sample?,
         actionHandler: @escaping (Action) -> Void)
    {
        self.samples = samples
        self.selected = selected
        self.actionHandler = actionHandler
    }
    
    var body: some View {
        ZStack(alignment: .leading) {
            display
            picker
        }
        .background {
            cancelButton
            upButton
            downButton
        }
    }
    
}

// MARK: SubViews

extension SamplePicker {
    
    private var display: some View {
        
        var text: String {
            guard !samples.isEmpty else { return "검색결과 없음" }
            
            if let selected = selected {
                return selected.description
            } else {
                return "미선택"
            }
        }
        
        return HStack {
            Text(text)
            Spacer()
            Image(systemName: "chevron.down")
                .foregroundColor(.blue)
        }
            .padding(3)
            .background { Color.white }
    }
    
    private var picker: some View {
        Picker("", selection: $selectedID) {
            Text(samples.isEmpty ? "검색결과 없음" : "미선택")
                .tag(nil as String?)
            ForEach(samples, id: \.id) { sample in
                Text(sample.description)
                    .tag(sample.id as String?)
            }
        }
        .onChange(of: selectedID) { idPicked($0) }
        .opacity(0)
    }
    
    private var cancelButton: some View {
        Button {
            actionHandler(.cancelled)
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
    func idPicked(_ id: String?) {
        let sample = samples.first { $0.id == id }
        actionHandler(.picked(sample: sample))
    }
    
    func sampleUp() {
        guard !samples.isEmpty else { return }
        let nowIndex = samples.firstIndex(where: { $0.id == selectedID }) ?? 0
        let nextIndex = (nowIndex + 1) % samples.count
        selectedID = samples[nextIndex].id
    }
    
    func sampleDown() {
        guard !samples.isEmpty else { return }
        let nowIndex = samples.firstIndex(where: { $0.id == selectedID }) ?? 0
        let nextIndex = (nowIndex - 1) >= 0 ? (nowIndex - 1) : (samples.count - 1)
        selectedID = samples[nextIndex].id
    }
}
