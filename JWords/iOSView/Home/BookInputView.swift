////
////  BookInputView.swift
////  JWords
////
////  Created by Jong Won Moon on 2023/04/26.
////
//
//import SwiftUI
//import Combine
//import ComposableArchitecture
//
//struct InputBook: ReducerProtocol {
//    
//    struct State: Equatable {
//        let set: StudySet?
//        var title: String
//        var preferredFrontType: FrontType
//        var isLoading: Bool = false
//        var alert: AlertState<Action>?
//        
//        init(set: StudySet? = nil) {
//            self.set = set
//            self.title = set?.title ?? ""
//            self.preferredFrontType = set?.preferredFrontType ?? .kanji
//        }
//        
//        var okButtonText: String {
//            return set == nil ? "추가" : "수정"
//        }
//        
//        var ableToAdd: Bool {
//            !title.isEmpty
//        }
//        
//        mutating func clear() {
//            title = ""
//            preferredFrontType = .kanji
//        }
//    }
//    
//    enum Action: Equatable {
//        case updateTitle(String)
//        case updatePreferredFrontType(FrontType)
//        case showErrorAlert(AppError)
//        case alertDismissed
//        case addButtonTapped
//        case cancelButtonTapped
//        case setAdded
//        case setEdited(StudySet)
//    }
//    
//    @Dependency(\.studySetClient) var setClient
//    
//    var body: some ReducerProtocol<State, Action> {
//        Reduce { state, action in
//            switch action {
//            case let .updateTitle(text):
//                state.title = text
//                return .none
//            case let .updatePreferredFrontType(type):
//                state.preferredFrontType = type
//                return .none
//            case .showErrorAlert(let error):
//                state.alert = error.simpleAlert(action: Action.self)
//                return .none
//            case .alertDismissed:
//                state.alert = nil
//                return .none
//            case .addButtonTapped:
//                guard !state.title.isEmpty else {
//                    return .task { .showErrorAlert(.emptyTitle) }
//                }
//                state.isLoading = true
//                let input = StudySetInput(
//                    title: state.title,
//                    isAutoSchedule: true,
//                    preferredFrontType: state.preferredFrontType)
//                if let set = state.set {
//                    let edited = try! setClient.update(set, input)
//                    state.isLoading = false
//                    return .task { .setEdited(edited) }
//                } else {
//                    state.isLoading = false
//                    try! setClient.insert(input)
//                    return .task { .setAdded }
//                }
//            case .setAdded:
//                state.title = ""
//                state.preferredFrontType = .kanji
//                return .none
//            default:
//                return .none
//            }
//        }
//    }
//}
//
//struct WordBookAddModal: View {
//    let store: StoreOf<InputBook>
//    
//    private let FONT_SIZE: CGFloat = 20
//    
//    var body: some View {
//        WithViewStore(store, observe: { $0 }) { vs in
//            VStack(spacing: 30) {
//                VStack {
//                    title("단어장 이름")
//                    textField(vs.binding(
//                        get: \.title,
//                        send: InputBook.Action.updateTitle))
//                }
//                VStack {
//                    title("앞면 유형")
//                    Picker("", selection: vs.binding(
//                        get: \.preferredFrontType,
//                        send: InputBook.Action.updatePreferredFrontType)
//                    ) {
//                        ForEach(FrontType.allCases, id: \.self) {
//                            Text($0.preferredTypeText)
//                        }
//                    }
//                    .pickerStyle(.segmented)
//                }
//                HStack {
//                    Spacer()
//                    inputButton("취소", foregroundColor: .black) { vs.send(.cancelButtonTapped) }
//                    Spacer()
//                    inputButton(vs.okButtonText,
//                                foregroundColor: !vs.ableToAdd ? .gray : .black)
//                        { vs.send(.addButtonTapped) }
//                        .disabled(!vs.ableToAdd)
//                    Spacer()
//                }
//            }
//            .padding(.horizontal, 10)
//            .presentationDetents([.medium])
//            .alert(
//              self.store.scope(state: \.alert),
//              dismiss: .alertDismissed
//            )
//            .loadingView(vs.isLoading)
//        }
//    }
//    
//    private func title(_ text: String) -> some View {
//        Text(text)
//            .font(.system(size: FONT_SIZE))
//            .bold()
//            .leadingAlignment()
//    }
//    
//    private func textField(_ text: Binding<String>) -> some View {
//        TextField("단어장 이름", text: text)
//            .padding(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
//            .font(.system(size: FONT_SIZE))
//            .clipShape(RoundedRectangle(cornerRadius: 10))
//            .defaultRectangleBackground()
//    }
//    
//    private func inputButton(_ text: String, foregroundColor: Color, onTapped: @escaping () -> Void) -> some View {
//        Button {
//            onTapped()
//        } label: {
//            Text(text)
//                .font(.system(size: FONT_SIZE))
//                .foregroundColor(foregroundColor)
//                .padding(.vertical, 10)
//                .padding(.horizontal, 20)
//                .defaultRectangleBackground()
//        }
//    }
//}
//
//struct WordBookAddModal_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationView {
//            WordBookAddModal(
//                store: Store(
//                    initialState: InputBook.State(),
//                    reducer: InputBook()._printChanges()
//                )
//            )
//        }
//    }
//}
