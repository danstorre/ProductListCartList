//
//  ProductListDomain.swift
//  OnlineStoreTCA
//
//  Created by Pedro Rojas on 17/08/22.
//

import Foundation
import ComposableArchitecture

struct ProductListDomain {
    struct State: Equatable {
        var dataLoadingStatus = DataLoadingStatus.notStarted
        var productListState: IdentifiedArrayOf<ProductDomain.State> = []
        
        var shouldShowError: Bool {
            dataLoadingStatus == .error
        }
        
        var isLoading: Bool {
            dataLoadingStatus == .loading
        }
    }
    
    enum Action: Equatable {
        case fetchProducts
        case fetchProductsResponse(TaskResult<[Product]>)
        case product(id: ProductDomain.State.ID, action: ProductDomain.Action)
    }
    
    struct Environment {
        var fetchProducts:  (@Sendable () async throws -> [Product])?
        var uuid: (@Sendable () -> UUID)?
    }
    
    static let reducer = Reducer<
        State, Action, Environment
    >.combine(
        ProductDomain.reducer.forEach(
            state: \.productListState,
            action: /ProductListDomain.Action.product(id:action:),
            environment: { _ in ProductDomain.Environment() }
        ),
        .init { state, action, environment in
            switch action {
            case .fetchProducts:
                if state.dataLoadingStatus == .success || state.dataLoadingStatus == .loading {
                    return .none
                }
                
                state.dataLoadingStatus = .loading
                return .task {
                    await .fetchProductsResponse(
                        TaskResult { try await environment.fetchProducts!() }
                    )
                }
            case .fetchProductsResponse(.success(let products)):
                state.dataLoadingStatus = .success
                state.productListState = IdentifiedArrayOf(
                    uniqueElements: products.map {
                        ProductDomain.State(
                            id: environment.uuid!(),
                            product: $0
                        )
                    }
                )
                return .none
            case .fetchProductsResponse(.failure(let error)):
                state.dataLoadingStatus = .error
                print(error)
                print("Error getting products, try again later.")
                return .none
            case .product(let id, let action):
                return .none
            }
        }
    )
    
}
