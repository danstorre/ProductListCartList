//
//  Root.swift
//  OnlineStoreTCA
//
//  Created by Daniel Torres on 1/20/23.
//

import Foundation
import ComposableArchitecture

final class Root {
    static func createView() -> TabViewContainer {
        TabViewContainer(
            store: Store(
                initialState: TabViewDomain.State(),
                reducer: TabViewDomain.reducer,
                environment: TabViewDomain.Environment()
            ),
            productListStore: Store(
                initialState: ProductListDomain.State(),
                reducer: ProductListDomain.reducer,
                environment: Self.productListDependencies()
            ),
            profileStore: Store(
                initialState: ProfileDomain.State(),
                reducer: ProfileDomain.reducer,
                environment: Self.profileDependencies()
            )
        )
    }
    
    
    private static func productListDependencies() -> ProductListDomain.Environment {
        ProductListDomain.Environment(
            fetchProducts: APIClient.live.fetchProducts,
            sendOrder: APIClient.live.sendOrder,
            uuid: { UUID() }
        )
    }
    
    private static func profileDependencies() -> ProfileDomain.Environment {
        ProfileDomain.Environment(
            fetchUserProfile: APIClient.live.fetchUserProfile
        )
    }
}
