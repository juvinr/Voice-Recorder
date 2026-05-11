import Foundation

final class MetadataStore {
    static let shared = MetadataStore()
    private init() {}

    private let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

    private let encoder: JSONEncoder = {
        let e = JSONEncoder()
        e.dateEncodingStrategy = .iso8601
        return e
    }()

    private let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        return d
    }()

    func save(_ metadata: RecordingMetadata, forID id: UUID) {
        guard let data = try? encoder.encode(metadata) else { return }
        let url = docs.appendingPathComponent("\(id.uuidString).json")
        try? data.write(to: url, options: .atomic)
    }

    func load(forID id: UUID) -> RecordingMetadata? {
        let url = docs.appendingPathComponent("\(id.uuidString).json")
        guard let data = try? Data(contentsOf: url) else { return nil }
        return try? decoder.decode(RecordingMetadata.self, from: data)
    }

    func delete(forID id: UUID) {
        let url = docs.appendingPathComponent("\(id.uuidString).json")
        try? FileManager.default.removeItem(at: url)
    }

    func loadAll() -> [(id: UUID, metadata: RecordingMetadata)] {
        let contents = (try? FileManager.default.contentsOfDirectory(
            at: docs,
            includingPropertiesForKeys: nil,
            options: .skipsHiddenFiles
        )) ?? []
        return contents
            .filter { $0.pathExtension == "json" }
            .compactMap { url -> (id: UUID, metadata: RecordingMetadata)? in
                let name = url.deletingPathExtension().lastPathComponent
                guard let id = UUID(uuidString: name),
                      let meta = load(forID: id) else { return nil }
                return (id: id, metadata: meta)
            }
    }
}
