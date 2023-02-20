//
//  ProductListView.swift
//  OnlineStoreTCA
//
//  Created by Pedro Rojas on 17/08/22.
//

import SwiftUI
import ComposableArchitecture

struct ProductListView: View {
    let store: Store<ProductListDomain.State,ProductListDomain.Action>
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            Group {
                if viewStore.isLoading {
                    ProgressView()
                        .frame(width: 100, height: 100)
                } else if viewStore.shouldShowError {
                    ErrorView(
                        message: "Oops, we couldn't fetch product list",
                        retryAction: { viewStore.send(.fetchProducts) }
                    )
                    
                } else {
                    List {
                        ForEachStore(
                            self.store.scope(
                                state: \.productListState,
                                action: ProductListDomain.Action
                                    .product(id: action:)
                            )
                        ) {
                            ProductCell(store: $0)
                        }
                    }
                }
            }
            .onAppear {
                viewStore.send(.fetchProducts)
            }
        }
        .tag("anyView")
        
    }
}

