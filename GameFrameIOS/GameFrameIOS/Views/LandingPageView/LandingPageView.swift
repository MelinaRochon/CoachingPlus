import SwiftUI

/**  This SwiftUI view represents the landing page of the app. It serves as the first screen
  users encounter when they open the app and provides navigation to other important
  sections of the app like the login screen, About page, and pricing information.

  The landing page includes:
  - A header section with the app name ("GameFrame") and tagline ("leveling up your game").
  - A "Log in" button that navigates to the login screen.
  - A "How we roll" section that leads to an informational page about the app.
  - A call-to-action section where users can create an account either as a coach or player.
  - A link to the Pricing page.

  The view uses a ZStack for layering the elements and provides a clean and organized layout
  using navigation links for smooth transitions to other views. The screen is scrollable to
  accommodate various sections without cluttering the UI.
*/
struct LandingPageView: View {
    
    /// Binding variable to control navigation to the Sign In view
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
                            .accessibilityIdentifier("gameframeWelcomeLabel")
                        
                        Text("leveling up your game")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .accessibilityIdentifier("gameframeSloganLabel")
                    }
                    
                    Spacer()
                    
                    NavigationLink(destination: LoginChoiceView(showSignInView: $showSignInView)){
                        HStack {
                            Text("Log in")
                                .foregroundColor(.gray)
                                .accessibilityIdentifier("loginButton")
                            
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
                    .accessibilityIdentifier("aboutPageNavLink")
                    
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
                    .accessibilityIdentifier("pricingNavLink")
                }
            }
            }.frame(maxWidth: .infinity)
        }
    }
}


#Preview {
    LandingPageView(showSignInView: .constant(false))
}
