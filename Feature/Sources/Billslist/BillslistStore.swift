//
//  BillslistStore.swift
//
//
//  Created by Marcos Meng on 2023/10/19.
//

import ComposableArchitecture
import Foundation
import Core

public struct BillslistStore: Reducer {
    public struct State: Equatable {
        var bills: [BillSectionData] = .stub()
        public init() {}
    }

    public enum Action: Equatable {
        case onAppear
        case onTap(BillModel)
    }

    public init() {}

    public var body: some Reducer<State, Action> {
        Reduce { _, action in
            switch action {
            case .onAppear:
                return .none
            default:
                return .none
            }
        }
    }
}
