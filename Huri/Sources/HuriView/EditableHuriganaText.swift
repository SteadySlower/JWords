//
//  EditableHuriganaText.swift
//  Huri
//
//  Created by JW Moon on 3/24/24.
//

import SwiftUI
import Huri

public struct EditableHuriganaText: View {
    let huris: [Huri]
    let fontSize: CGFloat
    let onHuriUpdated: (Huri) -> Void
    
    public init(huris: [Huri], fontsize: CGFloat = 20, onHuriUpdated: @escaping (Huri) -> Void) {
        self.huris = huris
        self.fontSize = fontsize
        self.onHuriUpdated = onHuriUpdated
    }

    public var body: some View {
        FlexBox(horizontalSpacing: 0, verticalSpacing: fontSize / 2, alignment: .leading) {
            ForEach(huris, id: \.id) { huri in
                EditableHuriUnit(huri: huri, fontSize: fontSize, onHuriUpdated: onHuriUpdated)
            }
        }
        .padding(.top, fontSize / 2)
    }
}
