//
//  MacHomeView.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/06/27.
//

import SwiftUI

struct MacHomeView: View {
    var body: some View {
        NavigationView {
            VStack (alignment: .leading) {
                BookAddNavigationView()
                WordAddNavigationView()
            }
        }
        .navigationViewStyle(.automatic)
    }
}

private struct BookAddNavigationView: View {
    var body: some View {
        NavigationLink {
            MacAddBookView()
        } label: {
            Text("add book")
        }
    }
}

private struct WordAddNavigationView: View {
    var body: some View {
        NavigationLink {
            MacAddWordView()
        } label: {
            Text("add word")
        }
    }
}

struct MacHomeView_Previews: PreviewProvider {
    static var previews: some View {
        MacHomeView()
    }
}
