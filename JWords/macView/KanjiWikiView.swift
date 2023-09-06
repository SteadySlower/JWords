//
//  KanjiWikiView.swift
//  JWords
//
//  Created by Jong Won Moon on 2023/09/05.
//

import SwiftUI

struct KanjiWikiView: View {
    
    let wikiKanjis: [WikiKanji]
    
    init() {
        let client = KanjiWikiClient()
        self.wikiKanjis = client.getAllWikiKanji()
    }
    
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(wikiKanjis, id: \.kanji) { kanji in
                    VStack {
                        Text("한자: \(kanji.kanji)")
                        Text("뜻: \(kanji.meaning)")
                        Text("음독: \(kanji.ondoku)")
                        Text("훈독: \(kanji.kundoku)")
                    }
                    .border(.black)
                    .padding(.vertical)
                }
            }
        }
    }
}

struct KanjiWikiView_Previews: PreviewProvider {
    static var previews: some View {
        KanjiWikiView()
    }
}
