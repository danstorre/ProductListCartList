//
//  PlusMinusDomain.swift
//  OnlineStoreTCA
//
//  Created by Pedro Rojas on 20/08/22.
//

import Foundation
import ComposableArchitecture

struct AddToCartDomain {
    struct State: Equatable {
        var count = 0
    }
    
    enum Action: Equatable {
        case didTapPlusButton
        case didTapMinusButton
    }
}
