//
//  Color+Extension.swift
//  JWords
//
//  Created by JW Moon on 2023/08/15.
//

import SwiftUI

extension Color {
    
    static func cellColor(_ studyState: StudyState) -> Color {
        switch studyState {
        case .undefined:
            return Color.white
        case .success:
            return Color(red: 207/256, green: 240/256, blue: 204/256)
        case .fail:
            return Color(red: 253/256, green: 253/256, blue: 150/256)
        }
    }
    
}
