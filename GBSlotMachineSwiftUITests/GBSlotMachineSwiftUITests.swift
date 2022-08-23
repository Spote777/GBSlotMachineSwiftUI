//
//  GBSlotMachineSwiftUITests.swift
//  GBSlotMachineSwiftUITests
//
//  Created by Павел Заруцков on 23.08.2022.
//

import XCTest
import Combine
@testable import GBSlotMachineSwiftUI

class GBSlotMachineSwiftUITests: XCTestCase {
    var cancellables = Set<AnyCancellable>()
    var viewModel: SlotViewModel!
    
    override func setUpWithError() throws {
        viewModel = SlotViewModel()
    }
    
    override func tearDownWithError() throws {
        cancellables = []
    }
    
    // Тест изменения текста кнопки в зависимости от состояния вьюмодели
    func testButtonTextChanged() {
        // Given
        let expected = "Крути эту штуку..."
        let expectation = XCTestExpectation()
        
        viewModel
            .$buttonText
            .dropFirst() // дропаем первое значение, заданное при инициализации
            .sink { value in XCTAssertEqual(value, expected); expectation.fulfill() }
            .store(in: &cancellables)
        
        // When
        viewModel.running = false
        
        // Then
        wait(for: [expectation], timeout: 5)
    }
    
    // Тест логики победы, когда выпадает три одинаковых эмодзи подряд
    func testWin() {
        // Given
        let expected = "Поздравляем, ты выиграл!"
        let expectation = XCTestExpectation()
        
        viewModel
            .$titleText
            .dropFirst()
            .sink { value in XCTAssertEqual(value, expected); expectation.fulfill() }
            .store(in: &cancellables)
        
        // When
        viewModel.slot1Emoji = "🦠"
        viewModel.slot2Emoji = "🦠"
        viewModel.slot3Emoji = "🦠"
        
        viewModel.running = false
        viewModel.gameStarted = true
        
        // Then
        wait(for: [expectation], timeout: 1)
    }
}
