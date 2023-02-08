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
    
    private let uuid: (@Sendable () -> UUID)
    private let effectFetchProducts: EffectTask<ProductListDomain.Action>
    
    init(uuid: @escaping (@Sendable () -> UUID),
         effectFetchProducts: EffectTask<ProductListDomain.Action>
    ) {
        self.uuid = uuid
        self.effectFetchProducts = effectFetchProducts
    }
    
    
    @discardableResult
    static func onLoad(enviroment: ProductListDomain.Environment) -> Task<[Product], Error> {
        return Task {
            try await enviroment.fetchProducts!()
        }
    }
}


extension ProductListDomain: ReducerProtocol {
    func reduce(into state: inout State, action: Action) -> ComposableArchitecture.EffectTask<Action> {
        switch action {
        case .fetchProducts:
            if state.dataLoadingStatus == .success || state.dataLoadingStatus == .loading {
                return .none
            }
            
            state.dataLoadingStatus = .loading
            return effectFetchProducts
        case .fetchProductsResponse(.success(let products)):
            state.dataLoadingStatus = .success
            state.productListState = IdentifiedArrayOf(
                uniqueElements: products.map {
                    ProductDomain.State(
                        id: uuid(),
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
            switch action {
            case .addToCart(let action):
                switch action {
                case .didTapMinusButton:
                    state.productListState[id: id]?.addToCartState.count -= 1
                case .didTapPlusButton:
                    state.productListState[id: id]?.addToCartState.count += 1
                }
            }
            return .none
        }
    }
}
