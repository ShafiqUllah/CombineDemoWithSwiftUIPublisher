//
//  ContentView.swift
//  CombineDemo
//
//  Created by Shafiq  Ullah on 11/21/23.
//

import SwiftUI
import Combine


class SubscriberViewModel : ObservableObject {
    @Published var count = 0
    @Published var textFiledText = ""
    @Published var textIsValid = false
    @Published var showButton = false
    
    var cancellable = Set<AnyCancellable>()
    
    init(){
        setUpTimer()
        addTextFiledSubscriber()
        addButtonSubscriber()
    }
    
    func addTextFiledSubscriber(){
        $textFiledText
            //.debounce(for: .seconds(0.5) , scheduler: DispatchQueue.main)// for 0.5 sec map will not call
            .map { (val) -> Bool in
                if val.count > 3 {
                    return true
                }
                return false
            }
            //.assign(to: \.textIsValid , on: self)
            .sink(receiveValue: { [weak self] val in
                guard let self = self else {return}
                self.textIsValid = val
            })
            .store(in: &cancellable)
    }
    
    func setUpTimer(){
        Timer
            .publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return}
                self.count += 1
                
                if self.count >= 50 {
                    for item in self.cancellable{
                        item.cancel()
                    }
                }
                
                
            }.store(in: &cancellable)
    }
    
    func addButtonSubscriber(){
        $textIsValid
            .combineLatest($count)
            .sink {[weak self] (isValid, count) in
                guard let self = self else {return}
                if isValid && count >= 20{
//                    print("\(isValid) and \(count)")
                    self.showButton = true
                }else{
                    self.showButton = false
                }
            }.store(in: &cancellable)
        
    }
}

struct ContentView: View {
    
    @StateObject var vm = SubscriberViewModel()
    
    var body: some View {
        
        VStack{
            Text("\(vm.count)")
                .font(.largeTitle)
            
            Text(vm.textIsValid.description)
            
            TextField("Enter text", text: $vm.textFiledText)
                .padding(.leading)
                .frame(height: 50)
                .background(.gray)
                .font(.headline)
                .cornerRadius(10)
                .overlay(
                    ZStack{
                        Image(systemName: "xmark")
                            .foregroundColor(.red)
                            .opacity(
                                vm.textFiledText.count < 1 ? 0.0 :
                                vm.textIsValid ? 0.0 : 1.0)
                        
                        Image(systemName: "checkmark")
                            .foregroundColor(.green)
                            .opacity(vm.textIsValid ? 1.0 : 0.0)
                    }
                        .font(.title3)
                        .padding(.trailing)
                    , alignment: .trailing)
            
            Button {
                
            } label: {
                Text("Submit".uppercased())
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(.blue)
                    .cornerRadius(10)
                    .opacity(vm.showButton ? 1.0 : 0.5)
            }
            .disabled(vm.showButton)

            
                
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
