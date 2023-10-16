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

        @BindingState var isReadOnly: Bool = false
        @BindingState var isReadWrite: Bool = false

        public init(participator: ParticipacerModel) {
            self.participatorModel = participator
        }
    }

    public enum Action: BindableAction, Equatable {
        case onAppear
        case something //TODO: update here
        case delete
        case tapReadOnly
        case tapReadWrite
        case binding(BindingAction<State>)
    }

    public init() {}

    public var body: some Reducer<State, Action> {
        BindingReducer()
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
                return .none
            default:
                return .none
            }
        }
    }
}
