
import SwiftUI
import ComposableArchitecture

struct NewTabViewContainer: View {
    let store: Store<TabViewDomain.State, TabViewDomain.Action>
    @State var productListStore: Store<ProductListContainerDomain.State, ProductListContainerDomain.Action>
    @State var profileStore: Store<ProfileDomain.State, ProfileDomain.Action>
    
    var fetchProducts:  (@Sendable () async throws -> [Product])?
    var uuid: (@Sendable () -> UUID)?
    
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            TabView(
                selection: viewStore.binding(
                    get: \.selectedTab,
                    send: TabViewDomain.Action.tabSelected
                )
            ) {
                ProductListContainerView(
                    productListView: {
                        ProductListViewDuplication(store: Store(
                            initialState: ProductListDomainDuplication.State(),
                            reducer: ProductListDomainDuplication.reducer,
                            environment: ProductListDomainDuplication.Environment(
                                fetchProducts: fetchProducts,
                                uuid: uuid
                            )
                        ))
                    }, 
                    store: productListStore
                )
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Products")
                }
                .tag(TabViewDomain.Tab.products)
                ProfileView(
                    store: profileStore
                )
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
                .tag(TabViewDomain.Tab.profile)
            }
        }
    }
}
