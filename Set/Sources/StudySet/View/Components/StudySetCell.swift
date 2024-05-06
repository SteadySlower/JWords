//
//  File.swift
//  
//
//  Created by JW Moon on 5/6/24.
//

import SwiftUI
import Cells
import Model

struct StudySetCell: View {
    
    let set: StudySet
    let onTapped: (StudySet) -> Void
    
    var body: some View {
        SetCell(
            title: set.title,
            dayFromToday: set.dayFromToday,
            dateTextColor: set.schedule.labelColor,
            onTapped: { onTapped(set) }
        )
    }
}
