
import SwiftUI
import ComposableArchitecture

struct NewTabViewContainer: View {
    let store: Store<TabViewDomain.State, TabViewDomain.Action>
    @State var profileStore: Store<ProfileDomain.State, ProfileDomain.Action>

    let productListContainerView: () -> ProductListContainerView
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            TabView(
                selection: viewStore.binding(
                    get: \.selectedTab,
                    send: TabViewDomain.Action.tabSelected
                )
            ) {
                productListContainerView()
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
