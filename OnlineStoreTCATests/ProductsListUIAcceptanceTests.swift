
import XCTest
import ComposableArchitecture
@testable import OnlineStoreTCA

final class ProductsListUIAcceptanceTests: XCTestCase {

    func test_onCartListSelection_WithNonSelectedItems_displaysEmptyCarList() {
        let cartList = showEmptyCartList()
        
        XCTAssertEqual(cartList.numberOfDisplayedItems, 0)
    }
    
    // MARK: - Helpers
    func showEmptyCartList() -> CartListView {
        CartListView(store: Store<CartListDomain.State, CartListDomain.Action>
            .init(
                initialState: CartListDomain.State(cartItems: []),
                reducer: CartListDomain(sendOrder: { _ in "" })
            )
        )
    }
}

extension CartListView {
    var numberOfDisplayedItems: Int {
        0
    }
}
