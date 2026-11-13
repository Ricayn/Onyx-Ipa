import SwiftUI
import AVKit

@MainActor
final class StreamPlayerModel: ObservableObject {
    @Published var player = AVPlayer()
    @Published var currentIndex = 0
    @Published var status = "Prêt"
    private var urls: [URL] = []
    private var title = ""
    private var failureObserver: NSObjectProtocol?

    deinit {
        if let failureObserver {
            NotificationCenter.default.removeObserver(failureObserver)
        }
    }

    func start(title: String, urls: [URL]) {
        self.title = title
        self.urls = urls
        currentIndex = 0
        playCurrent()
    }

    private func playCurrent() {
        guard urls.indices.contains(currentIndex) else {
            status = "Aucune source n'a pu être lue."
            return
        }
        status = "Lecture de la source \(currentIndex + 1)/\(urls.count)"
        if let failureObserver {
            NotificationCenter.default.removeObserver(failureObserver)
            self.failureObserver = nil
        }
        let item = AVPlayerItem(url: urls[currentIndex])
        player.replaceCurrentItem(with: item)
        failureObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemFailedToPlayToEndTime,
            object: item,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in self?.tryNextSource() }
        }
        player.play()
    }

    func tryNextSource() {
        guard currentIndex + 1 < urls.count else {
            status = "Toutes les sources ont échoué."
            return
        }
        currentIndex += 1
        playCurrent()
    }

    func stop() {
        player.pause()
        player.replaceCurrentItem(with: nil)
    }
}

struct PlayerView: View {
    let title: String
    let urls: [URL]
    @StateObject private var model = StreamPlayerModel()
    @EnvironmentObject private var library: LibraryStore

    var body: some View {
        VStack(spacing: 18) {
            VideoPlayer(player: model.player)
                .frame(height: 250)
                .background(.black)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            Text(title).font(.title2.bold())
            Text(model.status).font(.footnote).foregroundStyle(.secondary)
            HStack {
                Button("Réessayer") { model.start(title: title, urls: urls) }
                    .buttonStyle(.borderedProminent)
                Button("Source suivante") { model.tryNextSource() }
                    .buttonStyle(.bordered)
            }
            Text("Le lecteur accepte les URL vidéo directes autorisées (HLS .m3u8 ou MP4). Les plateformes officielles avec DRM ou connexion s'ouvrent dans leur application ou leur site.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Spacer()
        }
        .padding()
        .navigationTitle("Lecteur")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            library.addHistory(title: title, url: urls[0])
            model.start(title: title, urls: urls)
        }
        .onDisappear { model.stop() }
    }
}
