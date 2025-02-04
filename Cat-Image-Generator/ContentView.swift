/*
 By Bilash Sarkar
 2-1-25
 
 I created a cat image generator using a free API I found online "The Cat Api"
 This project is a work in progress, but the following is the foundation
 */


import SwiftUI
import Foundation
import AVFoundation
import Combine

// This sets up the Cat Image API I'll be incoorporating below
struct CatImage: Codable {
    let url: String
}

struct ContentView: View {
    


    
    // using this state to determine if the user can continue to the form
    @State private var sliderValue: Double = 0
    @State private var sliderCompleted: Bool = false
    
    
    //This is for the toggles in the form
    @State private var likeCats: Bool = false
    @State private var wantImages: Bool = false
    
    // for getting some data from the user
    @State private var name: String = ""
    @State private var favColor: String = ""
    
    // using this state to determine if the user can continue to the image generator
    @State private var nameSubmitted: Bool = false
    @State private var circleTapped: Bool = false
    
    // for setting the cat image url each time we fetch the data
    @State private var catImageURL: String? = nil
    
    
    
    @State private var audioPlayer: AVAudioPlayer? //for background music
    
    @State private var isMusicPlaying: Bool = false // Tracks music state
    
    var body: some View {
        ZStack {//I'm starting with a ZStack to set the solid background for the entire project
            Color.black.ignoresSafeArea() //The background for the entire project will be black.
            //ignores safe areas so the full screen is black in the background
            
            VStack { //I want each page (set by the if statements) to be vertically aligned as a backbone
                if !sliderCompleted {
                    Text("Random Cat Image\nGenerator") //creating a title, which I modify below
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                        .font(.system(size: 40))
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    Spacer()//filling the space between objects
                    
                    Image("sillycat3") //displaying an image to introduce the user to the app
                        .resizable()
                        .frame(width: 400, height: 360)
                        .padding(.top, 30)
                    
                    VStack { //creating a stack to hold the music toggler information.
                        Toggle("", isOn: $isMusicPlaying)
                            .labelsHidden()
                        
                        Text("Background Music")//Displaying name of the toggle
                            .foregroundColor(.white)
                            .fontWeight(.bold)
                            .onReceive(Just(isMusicPlaying)) { newValue in //functionallity of the toggle
                                if newValue {
                                    playSound() //plays sound
                                } else {
                                    audioPlayer?.pause() //pauses music
                                }
                            }
                    }
                    .padding(14)
                    
                    Text("Slide to Begin")
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                        .font(.system(size: 28))
                        .padding(.bottom, 20)
                    
                    ZStack(alignment: .leading) { //creating a depth based stack for the slider for overlappting colors
                        
                        Rectangle()//Top rectangle to display incomplete slider
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 300, height: 40)
                            .cornerRadius(10)
                        
                        
                        
                        Rectangle() //bottom rectangle to show progress
                            .fill(Color.pink)
                            .frame(width: CGFloat(sliderValue) * 300, height: 40)
                            .cornerRadius(10)
                        
                        Rectangle() //this is the part that the user slides, revealing the pink color below to show progress
                            .fill(Color.white)
                            .cornerRadius(10)
                            .frame(width: 30, height: 45)
                            .offset(x: CGFloat(sliderValue) * 270)
                            .gesture(DragGesture(minimumDistance: 0).onChanged { value in //creating the dragging functionallity
                                let newValue = min(max(0, value.location.x / 300), 1)
                                sliderValue = newValue
                                if newValue >= 1 {
                                    sliderCompleted = true
                                }
                            })
                    }
                    .padding(.horizontal, 50)
                    
                } else {
                    if nameSubmitted {
                        if circleTapped {//making sure that the on screen steps are complete to move to the cat image generator
                            VStack {//the same toggle stack as before, giving the user control over the music again
                                Toggle("", isOn: $isMusicPlaying)
                                    .labelsHidden()
                                
                                Text("Background Music")
                                    .foregroundColor(.white)
                                    .fontWeight(.bold)
                                    .onReceive(Just(isMusicPlaying)) { newValue in
                                        if newValue {
                                            playSound()
                                        } else {
                                            audioPlayer?.stop()
                                        }
                                    }
                            }
                            
                            if let imageURL = catImageURL { //formating the picture
                                AsyncImage(url: URL(string: imageURL)) { image in
                                    image.resizable()
                                        .scaledToFit()
                                        .frame(width: 500, height: 500)
                                        .clipShape(RoundedRectangle(cornerRadius: 15))
                                }
                                placeholder: {//using a system image if the cat image is taking too long to load.
                                    Image(systemName: "hourglass")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 80, height: 80)
                                        .foregroundColor(.white.opacity(0.7))
                                }
                            }
                            
                            Circle()//creating a circle that the user can tap to generate a new iamge
                                .frame(width: 100, height: 100)
                                .foregroundStyle(.linearGradient(colors: [.pink, .purple], startPoint: .topTrailing, endPoint: .bottomLeading))
                                .onTapGesture {//generates an image on tap
                                    fetchCatImage()
                                }
                                .padding(20)
                            
                            Text("Tap For More :)")
                                .font(.system(size: 30))
                                .foregroundColor(.white)
                            
                        } else {
                            Text("Hello, \(name)!\n") //greeting the user
                                .foregroundColor(.white)
                                .font(.system(size: 30))
                                .fontWeight(.semibold)
                            
                            Text("😻")
                                .font(.system(size: 100))
                            
                            Text("Tap Here To Begin!")
                                .foregroundColor(.white)
                                .font(.system(size: 30))
                                .fontWeight(.semibold)
                                .padding()
                            
                            Circle()
                                .frame(width: 150, height: 150)
                                .foregroundStyle(.linearGradient(colors: [.pink, .purple], startPoint: .topTrailing, endPoint: .bottomLeading))
                                .onTapGesture {
                                    circleTapped = true
                                    fetchCatImage() //fetching a cat image to start off on the next page so the user doesn't see a blank screen
                                }
                                .padding(50)
                        }
                    } else {
                        VStack {
                            Text("Random Cat Image\nGenerator")
                                .foregroundColor(.white)
                                .fontWeight(.bold)
                                .font(.system(size: 40))
                                .multilineTextAlignment(.center)
                                .padding()
                            
                            Spacer()
                            
                            Text("Let's Get to Know You First!") //prompting the user for information
                                .foregroundColor(.white)
                                .font(.system(size: 20))
                                .multilineTextAlignment(.center)
                            
                            VStack {
                                Form {
                                    TextField("Name: ", text: $name)//gathering name
                                        .disableAutocorrection(true)//I dont want auto correct here
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .padding()
                                    
                                    SecureField("Favorite Color", text: $favColor) //gathering favorite color. Using secure field for future edits
                                        .disableAutocorrection(true)//Autocorrect may be helpful here but I'm keeping it in case I change this form name to collect some other data
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .padding()
                                }
                                .frame(height: 250)
                                .scrollContentBackground(.hidden) //allows the user to scroll throught he form. not neccisary here, but I'll keep it for further changes
                                
                                HStack { //the form toggles will be next to each other rather than 1 on top of the other
                                    VStack {
                                        Toggle("", isOn: $likeCats)
                                            .labelsHidden()
                                        Text("Do You Like Cats?")
                                            .foregroundColor(.white)
                                    }
                                    .padding()
                                    
                                    VStack {
                                        Toggle("", isOn: $wantImages)
                                            .labelsHidden()
                                        Text("Want to See Cat Pictures?")
                                            .foregroundColor(.white)
                                    }
                                }
                                
                                Button {// a button to submit the data. Here I can add some validity checks in the future
                                    nameSubmitted = true
                                    if !likeCats || !wantImages {
                                        exit(0)
                                    }
                                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)//removes the keyboard from the screen
                                } label: { //naming the button and defining visuals
                                    Text("Submit")
                                        .font(.title2)
                                        .bold()
                                        .foregroundColor(.white)
                                }
                                .frame(height: 60)
                                .frame(maxWidth: 100)
                                .background(
                                    LinearGradient(colors: [.pink, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
                                )
                                .cornerRadius(20)
                                .padding()
                                
                                Image("sillycat1") //displaying another cat image
                                    .resizable()
                                    .scaledToFit()
                            }
                        }
                    }
                }
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
        }
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }//This removes the keyboard if the user taps off the keyboard

    }
    
    
    //this function controls the fetching of data from the cat api
    func fetchCatImage() {
        let apiURL = URL(string: "https://api.thecatapi.com/v1/images/search?api_key=live_Fpa13CSAS8X3IVvMPIMNYWR81x0dc2l8EkgfzvKUKesbVnl2JvCzE4ibNdySt3kN")!
            
        URLSession.shared.dataTask(with: apiURL) { data, _, _ in
            if let data = data, let decodedResponse = try? JSONDecoder().decode([CatImage].self, from: data) {//fetching the data
                DispatchQueue.main.async {
                    catImageURL = decodedResponse.first?.url //setting the url after it was decoded
                }
            }
        }.resume()
    }
    
    
    //this function handles the retreival of sound to play in the background on loop
    func playSound() {
        if audioPlayer == nil {
            let url = Bundle.main.url(forResource: "funnycat", withExtension: "mp3")
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url!)
                audioPlayer?.numberOfLoops = -1 // loop indefinitely
            }
            catch {
                print("Error loading audio: \(error)")
            }
        }
        
        if let player = audioPlayer, !player.isPlaying {
            player.play()
        }
    }
}

#Preview {
    ContentView()
}
