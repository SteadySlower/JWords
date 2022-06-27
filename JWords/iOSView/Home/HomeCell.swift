//
//  HomeCell.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/06/27.
//

import SwiftUI

struct HomeCell: View {
    private let cellWidth = Constants.Size.deviceWidth * 0.9
    
    var body: some View {
        NavigationLink {
            StudyView()
        } label: {
            HStack {
                VStack(alignment: .leading) {
                    Text("2과 단어장")
                    Text("2020/07/01")
                }
                .padding(.leading, 20)
                Spacer()
            }
            .frame(height: 100)
            .border(.gray, width: 1)
        }
    }
}

struct HomeCell_Previews: PreviewProvider {
    static var previews: some View {
        HomeCell()
    }
}
