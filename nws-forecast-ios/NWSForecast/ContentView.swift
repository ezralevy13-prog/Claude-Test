//
//  ContentView.swift
//  NWSForecast
//
//  Main view for the app
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = WeatherViewModel()
    @State private var isSearching = false

    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.isLoading && viewModel.afdData == nil {
                    ProgressView("Loading forecast...")
                        .progressViewStyle(.circular)
                } else if let errorMessage = viewModel.errorMessage, viewModel.afdData == nil {
                    ErrorView(message: errorMessage) {
                        Task {
                            await viewModel.refresh()
                        }
                    }
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
                            headerSection
                            forecastSections
                        }
                    }
                    .refreshable {
                        await viewModel.refresh()
                    }
                }
            }
            .navigationTitle("Forecast Discussion")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if viewModel.afdData != nil {
                        ShareLink(item: viewModel.shareText()) {
                            Image(systemName: "square.and.arrow.up")
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        isSearching.toggle()
                    } label: {
                        Image(systemName: "magnifyingglass")
                    }
                }
            }
            .searchable(text: $viewModel.searchText, isPresented: $isSearching, prompt: "Search location")
            .onSubmit(of: .search) {
                Task {
                    await viewModel.searchLocation(viewModel.searchText)
                    isSearching = false
                }
            }
            .task {
                viewModel.requestInitialLocation()
            }
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button {
                viewModel.refreshLocation()
            } label: {
                HStack {
                    Image(systemName: "location.fill")
                        .font(.subheadline)
                        .foregroundStyle(.blue)
                    Text(viewModel.locationName)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                    Spacer()
                    Image(systemName: "arrow.clockwise")
                        .font(.subheadline)
                        .foregroundStyle(.blue)
                }
            }
            .buttonStyle(.plain)

            HStack {
                Text(viewModel.lastUpdateText)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                if viewModel.isOffline {
                    Spacer()
                    Label("Offline", systemImage: "wifi.slash")
                        .font(.caption)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.orange, in: Capsule())
                }
            }

            Divider()
                .padding(.top, 8)
        }
        .padding(.horizontal)
        .padding(.top, 16)
        .padding(.bottom, 8)
    }

    private var forecastSections: some View {
        Group {
            if let data = viewModel.afdData {
                ForEach(data.sections) { section in
                    SectionView(section: section) {
                        viewModel.toggleSection(section.id)
                    }
                }
            }
        }
    }
}

struct SectionView: View {
    let section: AFDSection
    let onTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: onTap) {
                HStack {
                    Text(section.title)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Spacer()
                    Image(systemName: section.isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
                .background(Color(.systemGray6))
            }
            .buttonStyle(.plain)

            if section.isExpanded {
                Text(section.content)
                    .font(.body)
                    .foregroundStyle(.primary)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .textSelection(.enabled)
            }

            Divider()
        }
    }
}

struct ErrorView: View {
    let message: String
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundStyle(.orange)

            Text("Unable to Load Forecast")
                .font(.headline)

            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button(action: onRetry) {
                Label("Try Again", systemImage: "arrow.clockwise")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding()
                    .background(.blue, in: RoundedRectangle(cornerRadius: 10))
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
