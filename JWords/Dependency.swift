//
//  Dependency.swift
//  JWords
//
//  Created by JW Moon on 4/7/24.
//

import ComposableArchitecture
import XCTestDynamicOverlay
import tcaAPI

extension DependencyValues {
    public var pasteBoardClient: PasteBoardClient {
        get { self[PasteBoardClient.self] }
        set { self[PasteBoardClient.self] = newValue }
    }
    
    public var studySetClient: StudySetClient {
    get { self[StudySetClient.self] }
    set { self[StudySetClient.self] = newValue }
  }
    
    public var studyUnitClient: StudyUnitClient {
    get { self[StudyUnitClient.self] }
    set { self[StudyUnitClient.self] = newValue }
  }
    
    public var utilClient: UtilClient {
    get { self[UtilClient.self] }
    set { self[UtilClient.self] = newValue }
  }
    public var kanjiClient: KanjiClient {
    get { self[KanjiClient.self] }
    set { self[KanjiClient.self] = newValue }
  }
    
    public var scheduleClient: ScheduleClient {
    get { self[ScheduleClient.self] }
    set { self[ScheduleClient.self] = newValue }
  }
    
    public var ocrClient: OCRClient {
    get { self[OCRClient.self] }
    set { self[OCRClient.self] = newValue }
  }
    
    public var writingKanjiClient: WritingKanjiClient {
    get { self[WritingKanjiClient.self] }
    set { self[WritingKanjiClient.self] = newValue }
  }
    
    public var kanjiSetClient: KanjiSetClient {
    get { self[KanjiSetClient.self] }
    set { self[KanjiSetClient.self] = newValue }
  }
    
    public var huriganaClient: HuriganaClient {
    get { self[HuriganaClient.self] }
    set { self[HuriganaClient.self] = newValue }
  }

}

extension PasteBoardClient: DependencyKey, TestDependencyKey {}
extension StudySetClient: DependencyKey, TestDependencyKey {}
extension StudyUnitClient: DependencyKey, TestDependencyKey {}
extension UtilClient: DependencyKey, TestDependencyKey {}
extension KanjiClient: DependencyKey, TestDependencyKey {}
extension ScheduleClient: DependencyKey, TestDependencyKey {}
extension OCRClient: DependencyKey, TestDependencyKey {}
extension WritingKanjiClient: DependencyKey, TestDependencyKey {}
extension KanjiSetClient: DependencyKey, TestDependencyKey {}
extension HuriganaClient: DependencyKey, TestDependencyKey {}
