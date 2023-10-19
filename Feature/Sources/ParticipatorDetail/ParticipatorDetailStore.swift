//
//  ParticipatorDetailStore.swift
//  
//
//  Created by Marcos Meng on 2023/10/14.
//

import Foundation
import ComposableArchitecture
import Core

public struct ParticipatorDetailStore: Reducer {
    public struct State: Equatable {
        
        var participatorModel: ParticipacerModel

        var isReadOnly: Bool = false
        var isReadWrite: Bool = false

        public init(participator: ParticipacerModel) {
            self.participatorModel = participator
        }
    }

    public enum Action: Equatable {
        case onAppear
        case delete
        case tapReadOnly
        case tapReadWrite
        case tapBack
        case setReadOnly(Bool)
        case setReadWrite(Bool)
    }

    public init() {}

    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none
            case .tapReadOnly:
                state.isReadOnly = true
                state.isReadWrite = false
                return .none
            case .tapReadWrite:
                state.isReadOnly = false
                state.isReadWrite = true
                print("test isisisisis>")
                return .none
            case .setReadWrite(let value):
                state.isReadWrite = value
                return .none
            case .setReadOnly(let value):
                state.isReadOnly = value
                return .none
            case .delete:
                return .none
            case .tapBack:
                return .none
            }
        }
    }
}
