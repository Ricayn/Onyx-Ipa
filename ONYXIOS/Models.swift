import Foundation

enum MediaCategory: String, CaseIterable, Codable, Identifiable {
    case tv = "TV française"
    case films = "Films et séries"
    case anime = "Animés"
    var id: String { rawValue }
}

struct CatalogItem: Identifiable, Codable, Hashable {
    var id: String
    var title: String
    var category: MediaCategory
    var provider: String
    var description: String
    var website: URL
    var symbol: String
    var isFreeNote: String

    static let official: [CatalogItem] = [
        .init(id: "francetv", title: "france.tv", category: .tv, provider: "France Télévisions",
              description: "Direct, replay et programmes des chaînes France Télévisions.",
              website: URL(string: "https://www.france.tv/")!, symbol: "play.rectangle.fill",
              isFreeNote: "Accès et disponibilité selon les programmes."),
        .init(id: "arte", title: "ARTE", category: .tv, provider: "ARTE",
              description: "Programmes culturels, documentaires, séries et direct.",
              website: URL(string: "https://www.arte.tv/fr/")!, symbol: "a.circle.fill",
              isFreeNote: "Une grande partie des programmes est gratuite."),
        .init(id: "tf1plus", title: "TF1+", category: .tv, provider: "Groupe TF1",
              description: "Direct et replay des chaînes du groupe TF1.",
              website: URL(string: "https://www.tf1.fr/")!, symbol: "tv.fill",
              isFreeNote: "Certains contenus nécessitent un compte ou une offre."),
        .init(id: "m6plus", title: "M6+", category: .tv, provider: "Groupe M6",
              description: "Direct et replay des chaînes du groupe M6.",
              website: URL(string: "https://www.m6.fr/")!, symbol: "play.tv.fill",
              isFreeNote: "Disponibilité selon les droits et les programmes."),
        .init(id: "bfmtv", title: "BFMTV", category: .tv, provider: "BFM",
              description: "Actualité en continu et vidéos officielles.",
              website: URL(string: "https://www.bfmtv.com/")!, symbol: "newspaper.fill",
              isFreeNote: "Site officiel."),
        .init(id: "pluto", title: "Pluto TV", category: .films, provider: "Pluto TV",
              description: "Chaînes thématiques et films à la demande.",
              website: URL(string: "https://pluto.tv/fr/")!, symbol: "sparkles.tv.fill",
              isFreeNote: "Service gratuit avec publicité, selon disponibilité régionale."),
        .init(id: "rakuten", title: "Rakuten TV", category: .films, provider: "Rakuten TV",
              description: "Films et chaînes gratuites, ainsi que des locations et achats.",
              website: URL(string: "https://www.rakuten.tv/fr")!, symbol: "film.fill",
              isFreeNote: "Catalogue gratuit et payant selon les titres."),
        .init(id: "francevod", title: "ARTE Cinéma", category: .films, provider: "ARTE",
              description: "Films, cinéma d'auteur et collections ARTE.",
              website: URL(string: "https://www.arte.tv/fr/videos/cinema/")!, symbol: "popcorn.fill",
              isFreeNote: "Disponibilité variable selon les droits."),
        .init(id: "crunchyroll", title: "Crunchyroll", category: .anime, provider: "Crunchyroll",
              description: "Catalogue officiel d'animation japonaise.",
              website: URL(string: "https://www.crunchyroll.com/fr/")!, symbol: "eyes", 
              isFreeNote: "Compte et abonnement parfois nécessaires."),
        .init(id: "adn", title: "Animation Digital Network", category: .anime, provider: "ADN",
              description: "Plateforme française dédiée à l'animation japonaise.",
              website: URL(string: "https://animationdigitalnetwork.fr/")!, symbol: "play.rectangle",
              isFreeNote: "Catalogue soumis à abonnement et disponibilité.")
    ]
}

struct UserStream: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var name: String
    var category: MediaCategory
    var urls: [URL]
    var addedAt: Date = Date()
}

struct WatchRecord: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var title: String
    var url: URL
    var date: Date = Date()
}
