//
//  ScanGuide.swift
//  JWords
//
//  Created by JW Moon on 2023/09/28.
//

import SwiftUI

struct ScanGuide: View {
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("이미지 스캔하기")
                .font(.system(size: 20))
                .bold()
            Text("정면에서 찍을 수록 인식률이 높습니다.\n글자 크기가 클 수록 인식률이 높습니다.\n요미가나가 없이 한자만 있는 텍스트의 인식률이 높습니다.\n단어 사이에 간격이 넓을 수록 인식률이 높습니다.".localize())
                .font(.system(size: 12))
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding([.leading, .bottom], 10)
        .leadingAlignment()
    }
}
