import SwiftUI
import CommonUI

public struct InputSetTitle: View {
    
    let title: String
    
    public init(title: String) {
        self.title = title
    }
    
    public var body: some View {
        Text(title)
            .font(.system(size: 20))
            .bold()
            .leadingAlignment()
    }
}

#Preview {
    InputSetTitle(title: "단어장 이름")
}
