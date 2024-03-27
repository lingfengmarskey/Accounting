//
//  BillDetailStore.swift
//
//
//  Created by Marcos Meng on 2023/10/19.
//

import ComposableArchitecture
import Core
import Foundation

public struct BillDetailStore: Reducer {
    public struct State: Equatable {
        var billModel: Bill

        public init(billModel: Bill) {
            self.billModel = billModel
        }
    }

    public enum Action: Equatable {
        case onAppear
        case edit
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
