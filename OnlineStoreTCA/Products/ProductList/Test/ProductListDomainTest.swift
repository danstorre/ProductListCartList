//
//  ProductListDomainTest.swift
//  OnlineStoreTCA
//
//  Created by Pedro Rojas on 27/08/22.
//

import ComposableArchitecture
import XCTest

@testable import OnlineStoreTCA

@MainActor
class ProductListDomainTest: XCTestCase {
    
    override func setUp() async throws {
        UUID.uuIdTestCounter = 0
    }
    
    func testFetchProductsSuccess() async {
        let products: [Product] = [
            .init(
                id: 1,
                title: "ProductDemo",
                price: 10.5,
                description: "Hi mom!",
                category: "Category1",
                imageString: "image"
            ),
            .init(
                id: 2,
                title: "AnotherProduct",
                price: 99.99,
                description: "Hi Dad!",
                category: "Category2",
                imageString: "image2"
            ),
        ]
        
        let store = TestStore(
            initialState: ProductListDomain.State(),
            reducer: ProductListDomain.reducer,
            environment: ProductListDomain.Environment(
                fetchProducts: {
                    products
                },
                sendOrder: { _ in fatalError("unimplemented") },
                uuid: { UUID.newUUIDForTest }
            )
        )
        
        let productId1 = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
        let productId2 = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
        
        let identifiedArray = IdentifiedArrayOf(
            uniqueElements: [
                ProductDomain.State(
                    id: productId1,
                    product: products[0]
                ),
                ProductDomain.State(
                    id: productId2,
                    product: products[1]
                ),
            ]
        )
        
        await store.send(.fetchProducts) {
            $0.dataLoadingStatus = .loading
        }
        
        await store.receive(.fetchProductsResponse(.success(products))) {
            $0.productListState = identifiedArray
            $0.dataLoadingStatus = .success
        }
    }
    
    func testFetchProductsFailure() async {
        let error = APIClient.Failure()
        let store = TestStore(
            initialState: ProductListDomain.State(),
            reducer: ProductListDomain.reducer,
            environment: ProductListDomain.Environment(
                fetchProducts: {
                    throw error
                },
                sendOrder: { _ in fatalError("unimplemented") },
                uuid: { UUID.newUUIDForTest }
            )
        )
        
        await store.send(.fetchProducts) {
            $0.dataLoadingStatus = .loading
        }
        
        await store.receive(.fetchProductsResponse(.failure(error))) {
            $0.productListState = []
            $0.dataLoadingStatus = .error
        }
    }
    
    func testResetProductsToZeroAcferPayingOrder() async {
        let products: [Product] = [
            .init(
                id: 1,
                title: "ProductDemo",
                price: 10.5,
                description: "Hi mom!",
                category: "Category1",
                imageString: "image"
            ),
            .init(
                id: 2,
                title: "AnotherProduct",
                price: 99.99,
                description: "Hi Dad!",
                category: "Category2",
                imageString: "image2"
            ),
        ]
        
        let id1 = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
        let id2 = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
        
        let identifiedProducts = IdentifiedArrayOf(
            uniqueElements: [
                ProductDomain.State(
                    id: id1,
                    product: products[0]
                ),
                ProductDomain.State(
                    id: id2,
                    product: products[1]
                ),
            ]
        )
        
        let store = TestStore(
            initialState: ProductListDomain.State(
                productListState: identifiedProducts
            ),
            reducer: ProductListDomain.reducer,
            environment: ProductListDomain.Environment(
                fetchProducts: {
                    fatalError("unimplemented")
                },
                sendOrder: { _ in fatalError("unimplemented") },
                uuid: { UUID.newUUIDForTest }
            )
        )
        
        await store.send(
            .product(
                id: id1,
                action: .addToCart(.didTapPlusButton)
            )
        ) {
            $0.productListState[id: id1]?.addToCartState.count = 1
        }
        
        await store.send(
            .product(
                id: id1,
                action: .addToCart(.didTapPlusButton)
            )
        ) {
            $0.productListState[id: id1]?.addToCartState.count = 2
        }
        
        let expectedCartState = CartListDomain.State(
            cartItems: IdentifiedArrayOf(
                uniqueElements: [
                    CartItemDomain.State(
                        id: id1,
                        cartItem: CartItem(
                            id: id2,
                            product: products.first!,
                            quantity: 2
                        )
                    )
                ]
            )
        )
    }
}


extension UUID {
    // uuIdTestCounter needs to be set to 0 on setUp() method
    static var uuIdTestCounter: UInt = 0
    
    static var newUUIDForTest: UUID {
        defer {
            uuIdTestCounter += 1
        }
        return UUID(uuidString: "00000000-0000-0000-0000-\(String(format: "%012x", uuIdTestCounter))")!
    }
}
