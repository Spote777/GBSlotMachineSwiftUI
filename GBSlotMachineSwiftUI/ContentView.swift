//
//  ContentView.swift
//  GBSlotMachineSwiftUI
//
//  Created by Павел Заруцков on 23.08.2022.
//

import SwiftUI
import Combine

class SlotViewModel: ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    
    private let emojiSourceArray = ["🍋", "🍒", "🦠"]
    private let timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
    
    init() {
        timer
            .receive(on: RunLoop.main)
            .sink { _ in self.randomize() }
            .store(in: &cancellables)
        
        $running
            .receive(on: RunLoop.main)
            .map {
                guard !$0 && self.gameStarted else { return "Крути эту штуку..." }
                return self.slot1Emoji == self.slot2Emoji && self.slot2Emoji == self.slot3Emoji ? "Поздравляем, ты выиграл!" : "Не повезло, попробуй еще раз!"
            }
            .assign(to: \.titleText, on: self)
            .store(in: &cancellables)
        
        $running
            .receive(on: RunLoop.main)
            .map { $0 == true ? "Стоп!" : "Погнали!" }
            .assign(to: \.buttonText, on: self)
            .store(in: &cancellables)
    }
    
    private func randomize() {
        guard running else { return }
        slot1Emoji = emojiSourceArray[Int.random(in: 0...emojiSourceArray.count - 1)]
        slot2Emoji = emojiSourceArray[Int.random(in: 0...emojiSourceArray.count - 1)]
        slot3Emoji = emojiSourceArray[Int.random(in: 0...emojiSourceArray.count - 1)]
    }
    
    // input
    @Published var running = false
    @Published var gameStarted = false
    
    // output
    @Published var slot1Emoji = "🍒"
    @Published var slot2Emoji = "🦠"
    @Published var slot3Emoji = "🍋"
    
    @Published var titleText = ""
    @Published var buttonText = ""
}

struct SlotView <Content: View>: View {
    var content: () -> Content
    
    init(@ViewBuilder content: @escaping () -> Content) { self.content = content }
    
    var body: some View {
        content()
            .font(.system(size: 64.0))
            .transition(.asymmetric(insertion: .move(edge: .top), removal: .move(edge: .bottom)))
            .animation(.easeInOut)
            .id(UUID())
    }
}

struct ContentView: View {
    @ObservedObject private var slotViewModel = SlotViewModel()
    
    var body: some View {
        
        VStack {
            Spacer()
            Text(slotViewModel.titleText)
            Spacer()
            
            HStack {
                SlotView { Text(slotViewModel.slot1Emoji) }
                SlotView { Text(slotViewModel.slot2Emoji) }
                SlotView { Text(slotViewModel.slot3Emoji) }
            }
            
            Spacer()
            Button(action: { slotViewModel.running.toggle(); slotViewModel.gameStarted = true }, label: { Text(slotViewModel.buttonText) })
            Spacer()
        }
    }
}
