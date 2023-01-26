
import SwiftUI
import ComposableArchitecture

struct ProductsContainerView: View {
    let store: Store<ProductsContainerDomain.State,ProductsContainerDomain.Action>
    private let productListView: () -> ProductListView
    
    init(productListView: @escaping () -> ProductListView,
         store: Store<ProductsContainerDomain.State,ProductsContainerDomain.Action>) {
        self.productListView = productListView
        self.store = store
    }
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            NavigationView {
                productListView()
                .navigationTitle("Products")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            viewStore.send(.setCartView(isPresented: true))
                        } label: {
                            Text("Go to Cart")
                        }
                    }
                }
                .sheet(
                    isPresented: viewStore.binding(
                        get: \.shouldOpenCart,
                        send: ProductsContainerDomain.Action.setCartView(isPresented:)
                    )
                ) {
                    IfLetStore(
                        self.store.scope(
                            state: \.cartState,
                            action: ProductsContainerDomain.Action.cart
                        )
                    ) {
                        CartListView(store: $0)
                    }
                }
                
            }
        }
    }
}
