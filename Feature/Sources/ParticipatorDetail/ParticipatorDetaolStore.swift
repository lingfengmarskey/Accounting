//
//  ParticipatorDetaolStore.swift
//  
//
//  Created by Marcos Meng on 2023/10/14.
//

import Foundation
import ComposableArchitecture
import Core

public struct ParticipatorDetaolStore: Reducer {
    public struct State: Equatable {
        
        var participatorModel: ParticipacerModel
        
        public init(participator: ParticipacerModel) {
            self.participatorModel = participator
        }
    }

    public enum Action: Equatable {
        case onAppear
        case something //TODO: update here
    }

    public init() {}

    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none
            default:
                return .none
            }
        }
    }
}
