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
import InputAccounts
import Setting

@Reducer
public struct BillslistStore {
    @ObservableState
    public struct State{
        var bills: [BillSectionData] = .stub()
        @Presents var destination: Destination.State?

        public init(
            bills: [BillSectionData] = .stub(),
            destination: Destination.State? = nil
        ) {
            self.bills = bills
            self.destination = destination
        }
    }

    public enum Action {
        case onAppear
        case tapSetting
        case tapAdd(BillType?)
        case onTap(Bill)
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
            case .tapAdd(nil):
                state.destination = .addAccounts(.init())
                return .none
            default:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }

    @Reducer
    public enum Destination {
        case billDetail(BillDetailStore)
        case setting(SettingStore)
        case addAccounts(InputAccountsStore)
    }
    
}
