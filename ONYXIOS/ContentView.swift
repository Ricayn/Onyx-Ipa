import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var library: LibraryStore
    @State private var selectedTab = 0
    @State private var searchText = ""

    var body: some View {
        TabView(selection: $selectedTab) {
            catalog(category: .tv)
                .tabItem { Label("TV", systemImage: "tv") }.tag(0)
            catalog(category: .films)
                .tabItem { Label("Films", systemImage: "film") }.tag(1)
            catalog(category: .anime)
                .tabItem { Label("Animés", systemImage: "sparkles") }.tag(2)
            FavoritesView()
                .tabItem { Label("Favoris", systemImage: "heart") }.tag(3)
            SettingsView()
                .tabItem { Label("Réglages", systemImage: "gearshape") }.tag(4)
        }
        .tint(.red)
    }

    private func catalog(category: MediaCategory) -> some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    header(category.rawValue)
                    TextField("Rechercher", text: $searchText)
                        .textFieldStyle(.roundedBorder)
                    let official = CatalogItem.official.filter {
                        $0.category == category &&
                        (searchText.isEmpty || $0.title.localizedCaseInsensitiveContains(searchText) ||
                         $0.provider.localizedCaseInsensitiveContains(searchText))
                    }
                    LazyVStack(spacing: 12) {
                        ForEach(official) { item in
                            CatalogRow(item: item)
                        }
                    }
                    let custom = library.customStreams.filter { $0.category == category }
                    if !custom.isEmpty {
                        Text("Mes sources").font(.headline).padding(.top, 8)
                        ForEach(custom) { stream in
                            NavigationLink {
                                PlayerView(title: stream.name, urls: stream.urls)
                            } label: {
                                HStack {
                                    Image(systemName: "play.rectangle.fill").font(.title2).foregroundStyle(.red)
                                    VStack(alignment: .leading) {
                                        Text(stream.name).font(.headline)
                                        Text("\(stream.urls.count) source(s) enregistrée(s)").font(.caption).foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right").foregroundStyle(.secondary)
                                }
                                .padding().background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 14))
                            }
                        }
                    }
                }
                .padding()
            }
            .background(Color.black.ignoresSafeArea())
            .navigationBarHidden(true)
        }
    }

    private func header(_ title: String) -> some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text("ONYX").font(.system(size: 32, weight: .black, design: .rounded))
                Text(title.uppercased()).font(.caption.weight(.bold)).tracking(2).foregroundStyle(.red)
            }
            Spacer()
            Image(systemName: "play.rectangle.on.rectangle.fill")
                .font(.system(size: 32)).foregroundStyle(.red)
        }
        .padding(.vertical, 8)
    }
}

struct CatalogRow: View {
    let item: CatalogItem
    @EnvironmentObject private var library: LibraryStore
    @Environment(\.openURL) private var openURL

    var body: some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 12)
                .fill(LinearGradient(colors: [.red.opacity(0.8), .purple.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 58, height: 58)
                .overlay(Image(systemName: item.symbol).font(.title2).foregroundStyle(.white))
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title).font(.headline)
                Text(item.provider).font(.caption.weight(.semibold)).foregroundStyle(.secondary)
                Text(item.description).font(.caption).foregroundStyle(.secondary).lineLimit(2)
            }
            Spacer(minLength: 4)
            Button {
                library.toggleFavorite(item.id)
            } label: {
                Image(systemName: library.isFavorite(item.id) ? "heart.fill" : "heart")
                    .foregroundStyle(library.isFavorite(item.id) ? .red : .secondary)
                    .font(.title3)
            }
            .buttonStyle(.plain)
            Button {
                library.addHistory(title: item.title, url: item.website)
                openURL(item.website)
            } label: {
                Image(systemName: "arrow.up.right.square").font(.title3)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.white)
        }
        .padding(12)
        .background(Color.white.opacity(0.065), in: RoundedRectangle(cornerRadius: 16))
    }
}

struct FavoritesView: View {
    @EnvironmentObject private var library: LibraryStore
    private var items: [CatalogItem] {
        CatalogItem.official.filter { library.favorites.contains($0.id) }
    }
    var body: some View {
        NavigationStack {
            List {
                Section("Mes favoris") {
                    if items.isEmpty { Text("Aucun favori pour le moment.").foregroundStyle(.secondary) }
                    ForEach(items) { item in
                        CatalogRow(item: item).listRowBackground(Color.black)
                    }
                }
                Section("Historique") {
                    if library.history.isEmpty { Text("Ton historique apparaîtra ici.").foregroundStyle(.secondary) }
                    ForEach(library.history) { record in
                        VStack(alignment: .leading) {
                            Text(record.title)
                            Text(record.date.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption).foregroundStyle(.secondary)
                        }
                        .listRowBackground(Color.black)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.black)
            .navigationTitle("Favoris")
        }
    }
}

struct SettingsView: View {
    @EnvironmentObject private var library: LibraryStore
    @State private var showAdd = false

    var body: some View {
        NavigationStack {
            List {
                Section("Sources personnelles") {
                    Button { showAdd = true } label: {
                        Label("Ajouter une URL vidéo autorisée", systemImage: "plus.circle.fill")
                    }
                    ForEach(library.customStreams) { stream in
                        VStack(alignment: .leading) {
                            Text(stream.name)
                            Text(stream.urls.map(\.absoluteString).joined(separator: "\n"))
                                .font(.caption2).foregroundStyle(.secondary).lineLimit(2)
                        }
                        .swipeActions {
                            Button(role: .destructive) { library.deleteStream(stream) } label: {
                                Label("Supprimer", systemImage: "trash")
                            }
                        }
                    }
                }
                Section("Plateformes officielles") {
                    Text("Les services comme france.tv, TF1+, M6+, ARTE et Crunchyroll peuvent imposer une connexion, une application ou des droits géographiques. ONYX ouvre leur site officiel et ne contourne pas leurs protections.")
                        .font(.footnote)
                }
                Section("À propos") {
                    LabeledContent("Version", value: "1.0")
                    LabeledContent("Stockage", value: "Local sur cet appareil")
                }
            }
            .navigationTitle("Réglages")
            .sheet(isPresented: $showAdd) { AddStreamView() }
        }
    }
}

struct AddStreamView: View {
    @EnvironmentObject private var library: LibraryStore
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var rawURLs = ""
    @State private var category: MediaCategory = .tv
    @State private var error = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Informations") {
                    TextField("Nom de la source", text: $name)
                    Picker("Catégorie", selection: $category) {
                        ForEach(MediaCategory.allCases) { Text($0.rawValue).tag($0) }
                    }
                }
                Section("URL vidéo directe") {
                    TextEditor(text: $rawURLs).frame(minHeight: 120)
                    Text("Une URL par ligne. Formats pris en charge : HLS (.m3u8) ou MP4. Utilise uniquement des URL que tu es autorisé à diffuser.")
                        .font(.caption).foregroundStyle(.secondary)
                }
                if !error.isEmpty { Text(error).foregroundStyle(.red) }
            }
            .navigationTitle("Ajouter une source")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Annuler") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Enregistrer") { save() }
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty || rawURLs.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }

    private func save() {
        let lines = rawURLs.components(separatedBy: .newlines)
        let urls = lines.compactMap { line -> URL? in
            let value = line.trimmingCharacters(in: .whitespacesAndNewlines)
            guard let url = URL(string: value), ["https", "http"].contains(url.scheme?.lowercased() ?? ""),
                  url.host != nil else { return nil }
            return url
        }
        guard !urls.isEmpty else { error = "Aucune URL HTTP(S) valide."; return }
        library.addStream(name: name.trimmingCharacters(in: .whitespaces), category: category, urls: urls)
        dismiss()
    }
}
