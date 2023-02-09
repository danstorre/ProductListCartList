//
//  Root.swift
//  OnlineStoreTCA
//
//  Created by Daniel Torres on 1/20/23.
//

import Foundation
import ComposableArchitecture

final class Root {
    private lazy var productListStore = Store(
        initialState: ProductListDomain.State(),
        reducer: ProductListDomain(uuid: { UUID() },
                                   effectFetchProducts: EffectTask.task {
            await .fetchProductsResponse(
                TaskResult { try await APIClient.live.fetchProducts() }
            )
        })
    )
    
    private lazy var productListContainerDomainStore = Store(
        initialState: ProductsContainerDomain.State(),
        reducer: ProductsContainerDomain(uuid: { UUID() })
    )
    
    init() {}
    
    init(effectFetchProducts: EffectTask<ProductListDomain.Action>) {
        self.productListStore = Store(
            initialState: ProductListDomain.State(),
            reducer: ProductListDomain(
                uuid: { UUID() },
                effectFetchProducts: effectFetchProducts
            )
        )
    }
    
    func createMainView() -> TabViewContainer {
        TabViewContainer(
            store: Store(
                initialState: TabViewDomain.State(),
                reducer: TabViewDomain.reducer,
                environment: TabViewDomain.Environment()
            ),
            profileStore: Store(
                initialState: ProfileDomain.State(),
                reducer: ProfileDomain.reducer,
                environment: Self.profileDependencies()
            ),
            productListContainerView: createProductListContainerView
        )
    }
    
    public func createProductListContainerView() -> ProductsContainerView {
        ProductsContainerView(
            productListView: { [unowned self] in
                ProductListView(store: self.productListStore)
            },
            cartListView: { [unowned self] in
                IfLetStore(
                    self.productListContainerDomainStore.scope(
                        state: \.cartState,
                        action: ProductsContainerDomain.Action.cart
                    )
                ) {
                    CartListView(store: $0)
                }
            },
            store: productListContainerDomainStore
        )
    }
    
    private static func productListDuplicationDependencies() -> ProductListDomain.Environment {
        ProductListDomain.Environment(
            fetchProducts: APIClient.live.fetchProducts,
            uuid: { UUID() }
        )
    }
    
    private static func profileDependencies() -> ProfileDomain.Environment {
        ProfileDomain.Environment(
            fetchUserProfile: APIClient.live.fetchUserProfile
        )
    }
}
