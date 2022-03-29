//
//  ContentView.swift
//  LetterGuess
//
//  Created by Cengizhan Er on 28.03.2022.
//



// Refactor needed !!!
import SwiftUI

struct ContentView: View {
    @State private var newWord : String = ""
    @State private var usedWords = [String]()
    @State private var rootWord : String = "Knowing"
    @State private var yourScore : Int = 0
    
    @State private var errorTitle : String = ""
    @State private var errorMessage : String = ""
    @State private var showAlert : Bool = false
    @State private var myAllWords : [String] = []
    
    var body: some View {
        
        NavigationView {
            
            Form{
                Section(){
                    
                    TextField("Enter your word", text: $newWord)
                        .autocapitalization(.none)
                }
                Section{
                    ForEach(usedWords,id: \.self ) { word in
                        
                        HStack {
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                        
                    }
                }
            }
            .toolbar{
                ToolbarItemGroup(placement: .navigationBarLeading){
                    
                    Text("Your score is \(yourScore)            Change ")
                    
                    Button {
                        changeTheWord()
                    }label: {
                        Label("asdas", systemImage: "plus.rectangle")
                    }
                }
            }
            .navigationTitle(rootWord)
            .onSubmit(addNewWord)
            .onAppear(perform: startGame)
            .alert("Başarısız",isPresented: $showAlert){
                Button("OK",role: .cancel){ }
                
            }message: {
                Text("basarısız")
            }
            
        }
        
        
    }
    func changeTheWord () {
        rootWord = myAllWords.randomElement() ?? "Faileddd"
    }
    
    func addNewWord(){
        
        let answer = newWord.lowercased().trimmingCharacters(in:.whitespacesAndNewlines)
        
        guard answer.count > 0 else{ return }
        
        guard  isOriginal(word:answer) else{
            wordError(title: "You cannot enter the same words", message: "Please be creative !")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "This is not a real word", message: "Type a valid word !")
            return
        }
        guard isPossible(word: answer) else {
            wordError(title: "You cannot that assumption", message: "Use the letter that \(rootWord) contains")
            return
        }
        
        yourScore += answer.count
        
        withAnimation {
            usedWords.insert(answer, at: 0)
        }
        
        return
    }
    
    
    func wordError (title : String , message : String){
        errorTitle = title
        errorMessage = message
        showAlert = true
    }
    
    
    func isReal (word : String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelledRange.location == NSNotFound
    }
    
    func isOriginal (word : String) -> Bool {
        
        !usedWords.contains(word)
    }
    
    func isPossible (word : String) -> Bool {
        
        var tempWord = rootWord
        
        for letter in word {
            
            if let pos = tempWord.firstIndex(of: letter){
                tempWord.remove(at: pos)
            }else{
                return false
            }
        }
        
        return true
    }
    
    func startGame(){
        
        if let startWordsUrl=Bundle.main.url(forResource: "start", withExtension: "txt"){
            if let startWords = try? String(contentsOf: startWordsUrl){
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "Fatal Error"
                myAllWords = allWords
                return
            }
        }
        
        fatalError("The game cannot start because of the bundle..")
    }
    
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
