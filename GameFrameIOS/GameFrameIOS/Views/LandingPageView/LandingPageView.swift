import SwiftUI

struct LandingPageView: View {
    
    @Binding var showSignInView: Bool
    
    var body: some View {
        ZStack(alignment: .top) {
        NavigationView {
            
            VStack {
                
                // HEADER
                HStack {
                    VStack(alignment: .leading) {
                        Text("GameFrame")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("leveling up your game")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    NavigationLink(destination: LoginChoiceView(showSignInView: $showSignInView)){
                        HStack {
                            Text("Log in").foregroundColor(.gray)
                            
                            Image(systemName: "person.circle")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(.horizontal)
                
                Spacer().frame(height: 20)
                ScrollView {
                    
                    // HOW WE ROLL SECTION
                    NavigationLink(destination: AboutPageView()){
                        HStack {
                            Text("How we roll")
                                .foregroundColor(.gray)
                                .font(.headline)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal)
                    }
                    
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 150)
                        .cornerRadius(10)
                        .padding(.horizontal)
                    
                    Spacer().frame(height: 20)
                    
                    // CALL TO ACTION
                    VStack(spacing: 10) {
                        Text("Get started with GameFrame!")
                            .font(.title3)
                            .fontWeight(.bold)
                        
                        Text("I am a...")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        HStack(spacing: 10) {
                            NavigationLink(destination: CoachCreateAccountView(showSignInView: $showSignInView)) {
                                Text("Coach")
                                    .font(.headline)
                                    .padding()
                                    .frame(width: 100, height: 40)
                                    .background(Color.black)
                                    .foregroundColor(.white)
                                    .clipShape(Capsule())
                            }
                            
                            NavigationLink(destination: PlayerCreateAccountView(showSignInView: $showSignInView, viewModel: AuthenticationModel())) {
                                Text("Player")
                                    .font(.headline)
                                    .padding()
                                    .frame(width: 100, height: 40)
                                    .background(Color.black)
                                    .foregroundColor(.white)
                                    .clipShape(Capsule())
                            }
                        }
                    }
                    
                    
                    Spacer().frame(height: 20)
                    
                    // PRICING LINK
                    NavigationLink(destination: PricingPageView()) {
                        HStack {
                            Text("Pricing")
                                .foregroundColor(.gray)
                                .font(.headline)
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            /*.toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("GameFrame")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text("leveling up your game")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        
                        
                    }.frame(height: 80)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: LoginChoiceView(showSignInView: $showSignInView)) {
                        HStack {
                            Text("Log in")
                                .foregroundColor(.gray)
                            
                            Image(systemName: "person.circle")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundColor(.gray)
                        }.padding(.top)
                    }.frame(height: 80)
                }
            }*/
            }.frame(maxWidth: .infinity)
        }
    }
}


#Preview {
    LandingPageView(showSignInView: .constant(false))
}
