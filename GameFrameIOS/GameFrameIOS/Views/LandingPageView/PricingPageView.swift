//
//  PricingPageView.swift
//  GameFrameIOS
//
//  Created by Caterina Bosi on 2025-02-13.
//

import SwiftUI

/**  This SwiftUI view represents the pricing page of the app. It displays various subscription
  plans for the users to choose from. The user can view different pricing tiers for the app,
  including Free, Plus, and Premium plans.

  The view includes the following sections:
  - A title prompting users to view available plans.
  - A set of buttons corresponding to each plan: Free, Plus, and Premium. These buttons are styled
    as capsules and update the displayed plan description when clicked.
  - A dynamic text box that shows the description of the selected plan.

  The page is implemented using a `ScrollView` to ensure all content fits on the screen and remains
  scrollable. Each plan button's action updates the `selectedPlan` state, which in turn updates the
  text box to reflect the details of the selected plan.
*/
struct PricingPageView: View {
    @State private var selectedPlan: String = "Select a plan to see details"

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                ScrollView {
                    Spacer().frame(height: 50)
                    VStack(spacing: 10) {
                                Text("View our plans!")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .accessibilityIdentifier("pricingPage.title")
                                HStack(spacing: 10) {
                                    ForEach(PricingPlan.allCases, id: \.self) { plan in
                                        pricingButton(title: plan.rawValue, description: plan.description)
                                            .accessibilityIdentifier(plan.accessibilityId)
                                    }
                                }
                            }
                            .padding()
                                        
                    // Dynamic Text Box
                    Text(selectedPlan)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                        .padding(.horizontal, 20)
                        .multilineTextAlignment(.center)
                        .accessibilityIdentifier("pricing.selectedPlan.label")
                }
            }
        }
    }
    
    /// Function to create the pricing plan buttons
    func pricingButton(title: String, description: String) -> some View {
        Button(action: {
            selectedPlan = description
        }) {
            Text(title)
                .font(.headline)
                .padding()
                .frame(width: 120, height: 40)
                .background(selectedPlan == description ? Color.gray : Color.black) // Change color if selected
                .foregroundColor(.white)
                .clipShape(Capsule())
        }
    }
}


#Preview {
    PricingPageView()
}
