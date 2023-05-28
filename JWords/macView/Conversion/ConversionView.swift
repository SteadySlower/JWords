//
//  MacStudyView.swift
//  JWords
//
//  Created by JW Moon on 2023/05/21.
//

import SwiftUI
import ComposableArchitecture

struct ConversionList: ReducerProtocol {
    struct State: Equatable {
        var coredataSet = SelectStudySet.State(pickerName: "CoreData 단어장")
        var firebaseBook = SelectWordBook.State(pickerName: "Firebase 단어장")
        var typeForAll: UnitType? = nil
        var words: IdentifiedArrayOf<FirebaseWord.State> = []
        var units: IdentifiedArrayOf<CoreDataWord.State> = []
        
        var filteredWords: IdentifiedArrayOf<FirebaseWord.State> {
            words.filter { !$0.converted }
        }
        
        var isLoading = false
        
        var alert: AlertState<Action>?
        
        mutating func setResetAlertState() {
            alert = AlertState<Action> {
                TextState("코어데이터 전체 삭제")
            } actions: {
                ButtonState(role: .cancel) {
                    TextState("취소")
                }
                ButtonState(role: .destructive, action: .resetCoreData) {
                    TextState("삭제")
                }
            } message: {
                TextState("코어 데이터의 모든 데이터 삭제됨")
            }
        }
    }
    
    enum Action: Equatable {
        case selectStudySet(action: SelectStudySet.Action)
        case selectWordBook(action: SelectWordBook.Action)
        case updateAllType(UnitType?)
        case wordsResponse(TaskResult<[Word]>)
        case unit(id: CoreDataWord.State.ID, action: CoreDataWord.Action)
        case word(id: FirebaseWord.State.ID, action: FirebaseWord.Action)
        case onConverted(TaskResult<StudyUnit>)
        case onAllConverted(TaskResult<[StudyUnit]>)
        case totalConvertButtonTapped
        case closeSetButtonTapped
        case resetButtonTapped
        case resetCoreData
        case alertDismissed
    }
    
    private let cd = CoreDataClient.shared
    private let iu = CKImageUploader.shared
    @Dependency(\.wordBookClient) var wordBookClient
    @Dependency(\.wordClient) var wordClient
    private enum fetchBooksID {}
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .resetButtonTapped:
                state.setResetAlertState()
            case .resetCoreData:
                try! cd.resetCoreData()
            case .alertDismissed:
                state.alert = nil
            case .selectStudySet(let action):
                switch action {
                case .idUpdated:
                    guard let set = state.coredataSet.selectedSet else {
                        state.units = []
                        break
                    }
                    state.units = IdentifiedArrayOf(
                        uniqueElements: try! cd.fetchUnits(of: set).map { CoreDataWord.State(unit: $0) })
                default: break
                }
            case .closeSetButtonTapped:
                guard let nowSet = state.coredataSet.selectedSet else { break }
                try! cd.closeSet(nowSet)
                state.coredataSet.resetState()
                state.units = []
                state.coredataSet.sets = try! cd.fetchSets()
            case .selectWordBook(let action):
                switch action {
                case .bookUpdated:
                    guard let book = state.firebaseBook.selectedBook else {
                        state.words = []
                        return .none
                    }
                    state.typeForAll = nil
                    return .task {
                        await .wordsResponse( TaskResult { try await wordClient.words(book) } )
                    }
                default: break
                }
            case .updateAllType(let type):
                state.typeForAll = type
                if let type = type {
                    state.words = IdentifiedArrayOf(
                        uniqueElements: state.words.map { FirebaseWord.State(word: $0.word, type: type) })
                }
            case let .wordsResponse(.success(words)):
                state.words = IdentifiedArrayOf(
                    uniqueElements: words.map {
                        FirebaseWord.State(word: $0)
                    })
            case .word(_, let action):
                switch action {
                case let .onMove(conversionInput):
                    guard let set = state.coredataSet.selectedSet else { break }
                    return .task {
                        await .onConverted( TaskResult { try await cd.convert(input: conversionInput, in: set) } )
                    }
                case let .onEditAndMove(unit, meaning):
                    guard let set = state.coredataSet.selectedSet else { break }
                    return .task {
                        await .onConverted( TaskResult { try await cd.convert(unit: unit, newMeaning: meaning, in: set) } )
                    }
                case .updateType:
                    state.typeForAll = nil
                default: break
                }
            case let .onConverted(.success(unit)):
                guard let set = state.coredataSet.selectedSet else { break }
                if let index = state.words.index { $0.conversionInput.kanjiText == unit.kanjiText } {
                    state.words[index].onCoverted()
                }
                state.units = IdentifiedArrayOf(
                    uniqueElements: try! cd.fetchUnits(of: set).map { CoreDataWord.State(unit: $0) })
            case .totalConvertButtonTapped:
                guard let set = state.coredataSet.selectedSet else {
                    let book = state.firebaseBook.selectedBook!
                    try! cd.convertBook(book: book)
                    state.coredataSet.sets = try! cd.fetchSets()
                    state.coredataSet.selectedID = state.coredataSet.sets[0].id
                    return .none
                }
                state.isLoading = true
                var inputs = [ConversionInput]()
                for i in 0..<state.words.count {
                    if let exist = try! cd.checkIfExist(state.words[i].conversionInput.kanjiText) {
                        state.words[i].overlappingUnit = exist
                        state.words[i].overlappingMeaningText = exist.meaningText ?? ""
                    } else {
                        inputs.append(state.words[i].conversionInput)
                    }
                }
                return .task { [inputs = inputs] in
                    await .onAllConverted( TaskResult { try await cd.convert(inputs: inputs, in: set) } )
                }
            case let .onAllConverted(.success(units)):
                for unit in units {
                    if let index = state.words.index { $0.conversionInput.kanjiText == unit.kanjiText } {
                        state.words[index].onCoverted()
                    }
                }
                guard let set = state.coredataSet.selectedSet else { break }
                state.units = IdentifiedArrayOf(
                    uniqueElements: try! cd.fetchUnits(of: set).map { CoreDataWord.State(unit: $0) })
                state.isLoading = false
            default:
                break
            }
            return .none
        }
        .forEach(\.units, action: /Action.unit(id:action:)) {
            CoreDataWord()
        }
        .forEach(\.words, action: /Action.word(id:action:)) {
            FirebaseWord()
        }
        Scope(state: \.coredataSet, action: /Action.selectStudySet(action:)) {
            SelectStudySet()
        }
        Scope(state: \.firebaseBook, action: /Action.selectWordBook(action:)) {
            SelectWordBook()
        }
    }
    
}

struct ConversionView: View {
    
    let store: StoreOf<ConversionList>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { vs in
            VStack {
                HStack {
                    VStack {
                        HStack {
                            Button("Core Data 리셋") {
                                vs.send(.resetButtonTapped)
                            }
                            .disabled(vs.isLoading)
                            Button("현재 Set close") {
                                vs.send(.closeSetButtonTapped)
                            }
                            .disabled(vs.isLoading)
                        }
                        StudySetPicker(store: store.scope(
                            state: \.coredataSet,
                            action: ConversionList.Action.selectStudySet(action:))
                        )
                        ScrollView {
                            VStack(spacing: 10) {
                                ForEachStore(
                                    self.store.scope(state: \.units, action: ConversionList.Action.unit(id:action:))
                                  ) {
                                      CoreDataWordCell(store: $0)
                                  }
                            }
                        }
                    }
                    .loadingView(vs.isLoading)
                    if !vs.filteredWords.isEmpty {
                        VStack {
                            Button("<-") {
                                vs.send(.totalConvertButtonTapped)
                            }
                            .disabled(vs.isLoading)
                            Spacer()
                        }
                        .padding(.top, 30)
                    }
                    VStack {
                        WordBookPicker(store: store.scope(
                            state: \.firebaseBook,
                            action: ConversionList.Action.selectWordBook(action:))
                        )
                        Picker("타입 일괄 변경", selection:
                                vs.binding(
                                     get: \.typeForAll,
                                     send: ConversionList.Action.updateAllType)
                        ) {
                            Text("일괄 선택 없음")
                                .tag(nil as UnitType?)
                            ForEach(UnitType.allCases, id: \.self) { type in
                                Text(type.description)
                                    .tag(type as UnitType?)
                            }
                        }
                        ScrollView {
                            VStack(spacing: 10) {
                                ForEachStore(
                                    self.store.scope(state: \.filteredWords, action: ConversionList.Action.word(id:action:))
                                  ) {
                                      FirebaseWordCell(store: $0)
                                  }
                            }
                        }
                    }
                }
            }
            .alert(
              self.store.scope(state: \.alert),
              dismiss: .alertDismissed
            )
        }
    }
}

struct MacStudyView_Previews: PreviewProvider {
    static var previews: some View {
        ConversionView(
            store: Store(
                initialState: ConversionList.State(),
                reducer: ConversionList()._printChanges()
            )
        )
    }
}
