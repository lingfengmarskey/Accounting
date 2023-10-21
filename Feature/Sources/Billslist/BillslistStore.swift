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
import Setting

public struct BillslistStore: Reducer {
    public struct State: Equatable {
        var bills: [BillSectionData] = .stub()

        @PresentationState var destination: Destination.State?

        public init() {}
    }

    public enum Action: Equatable {
        case onAppear
        case tapSetting
        case tapAdd(BillType?)
        case onTap(BillModel)
        case destination(PresentationAction<Destination.Action>)
    }

    public init() {}

    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none
            case let .onTap(bill):
                state.destination = .billDetail(.init(billModel: bill))
                return .none
            case .tapSetting:
                state.destination = .setting(.init())
                return .none
            default:
                return .none
            }
        }
        .ifLet(\.$destination, action: /Action.destination) {
            Destination()
        }
    }

    public struct Destination: Reducer {
        public enum State: Equatable {
            case billDetail(BillDetailStore.State)
            case setting(SettingStore.State)
        }

        public enum Action: Equatable {
            case billDetail(BillDetailStore.Action)
            case setting(SettingStore.Action)
        }

        public var body: some Reducer<State, Action> {
            Scope(state: /State.billDetail, action: /Action.billDetail) {
                BillDetailStore()
            }
            Scope(state: /State.setting, action: /Action.setting) {
                SettingStore()
            }
        }
    }
}
