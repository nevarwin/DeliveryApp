//
//  ContentView.swift
//  DeliveryApp
//
//  Created by raven on 11/18/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var menuController: MenuController
    
    var body: some View {
        NavigationStack {
            Group {
                if menuController.menuItems.isEmpty {
                    ContentUnavailableView("No dishes yet",
                                           systemImage: "takeoutbag.and.cup.and.straw.fill",
                                           description: Text("Pull to refresh to load the house specials."))
                } else {
                    List {
                        ForEach(menuController.menuItems) { item in
                            NavigationLink {
                                MenuDetailView(item: item)
                            } label: {
                                MenuRow(item: item)
                            }
                            .listRowSeparator(.hidden)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Local Eats")
            .toolbar {
                Button {
                    menuController.loadMenu()
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
                .accessibilityLabel("Refresh menu")
            }
        }
    }
}

private struct MenuRow: View {
    let item: MenuItem
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(.orange.opacity(0.15))
                    .frame(width: 56, height: 56)
                Image(systemName: item.imageName)
                    .font(.system(size: 24))
                    .foregroundStyle(.orange)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.headline)
                Text(item.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            Text(item.price, format: .currency(code: "USD"))
                .font(.headline)
        }
        .padding(.vertical, 8)
    }
}

private struct MenuDetailView: View {
    let item: MenuItem
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Image(systemName: item.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 180)
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .frame(maxWidth: .infinity)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text(item.name)
                        .font(.largeTitle.bold())
                    Text(item.description)
                        .font(.body)
                        .foregroundStyle(.secondary)
                    Text(item.price, format: .currency(code: "USD"))
                        .font(.title2.bold())
                }
            }
            .padding()
        }
        .navigationTitle("Dish details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ContentView()
        .environmentObject(MenuController())
}
