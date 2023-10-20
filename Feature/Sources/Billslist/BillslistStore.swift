//
//  BillslistStore.swift
//
//
//  Created by Marcos Meng on 2023/10/19.
//

import BillDetail
import ComposableArchitecture
import Core
import Domain
import Foundation

public struct BillslistStore: Reducer {
    public struct State: Equatable {
        var bills: [BillSectionData] = .stub()

        @PresentationState var detail: BillDetailStore.State?

        public init() {}
    }

    public enum Action: Equatable {
        case onAppear
        case tapAdd(BillType?)
        case onTap(BillModel)
        case detail(PresentationAction<BillDetailStore.Action>)
    }

    public init() {}

    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none
            case let .onTap(bill):
                state.detail = .init(billModel: bill)
                return .none
            default:
                return .none
            }
        }
        .ifLet(\.$detail, action: /Action.detail) {
            BillDetailStore()
        }
    }
}
