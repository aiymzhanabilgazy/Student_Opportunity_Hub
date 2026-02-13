import Foundation
import FirebaseDatabase

protocol CommentsServiceProtocol {
    func observeComments(opportunityId: String,
                         onChange: @escaping ([Comment]) -> Void)
    func stopObserving(opportunityId: String)

    func addComment(opportunityId: String, comment: Comment) async throws
    func updateComment(opportunityId: String, commentId: String, newText: String) async throws
    func deleteComment(opportunityId: String, commentId: String) async throws
}

final class CommentsService: CommentsServiceProtocol {

    private let root: DatabaseReference

    // ✅ храним все handles на oppId вместе
    private var handles: [String: [DatabaseHandle]] = [:]

    init() {
        self.root = Database.database(
            url: "https://studentopportunityhub-default-rtdb.europe-west1.firebasedatabase.app"
        ).reference()
    }

    private func commentsRef(_ oppId: String) -> DatabaseReference {
        root.child("comments").child(oppId)
    }

    // MARK: - Realtime READ (childAdded/changed/removed)

    func observeComments(opportunityId: String,
                         onChange: @escaping ([Comment]) -> Void) {

        stopObserving(opportunityId: opportunityId)

        let ref = commentsRef(opportunityId)

        // локальное состояние
        var map: [String: Comment] = [:]

        func emit() {
            let items = map.values.sorted { $0.createdAt < $1.createdAt }
            DispatchQueue.main.async { onChange(items) }
        }

        let hAdded = ref.observe(.childAdded) { snap in
            let dict = Self.asDict(snap.value)
            guard !dict.isEmpty else {
                print("❌ childAdded: empty dict raw=", snap.value ?? "nil")
                return
            }

            if let c = Self.decodeComment(id: snap.key, dict: dict) {
                map[snap.key] = c
                emit()
            } else {
                print("❌ decode failed (added) id=", snap.key, "dict=", dict)
            }
        }

        let hChanged = ref.observe(.childChanged) { snap in
            let dict = Self.asDict(snap.value)
            guard !dict.isEmpty else { return }

            if let c = Self.decodeComment(id: snap.key, dict: dict) {
                map[snap.key] = c
                emit()
            } else {
                print("❌ decode failed (changed) id=", snap.key, "dict=", dict)
            }
        }

        let hRemoved = ref.observe(.childRemoved) { snap in
            map.removeValue(forKey: snap.key)
            emit()
        }

        handles[opportunityId] = [hAdded, hChanged, hRemoved]

        // Debug initial
        ref.getData { error, snapshot in
            if let error {
                print("❌ getData error:", error.localizedDescription)
            } else {
                print("📥 initial getData oppId=\(opportunityId) value=", snapshot?.value ?? "nil")
            }
        }
    }

    func stopObserving(opportunityId: String) {
        let ref = commentsRef(opportunityId)
        if let hs = handles[opportunityId] {
            hs.forEach { ref.removeObserver(withHandle: $0) }
            handles.removeValue(forKey: opportunityId)
        }
    }

    // MARK: - CREATE

    func addComment(opportunityId: String, comment: Comment) async throws {
        let ref = commentsRef(opportunityId).childByAutoId()

        // ✅ createdAt делаем серверным временем (ms)
        let payload: [String: Any] = [
            "opportunityId": opportunityId,
            "authorUid": comment.authorUid,
            "userName": comment.userName,
            "text": comment.text,
            "createdAt": ServerValue.timestamp()
        ]

        try await setValue(ref: ref, value: payload)
    }

    // MARK: - UPDATE

    func updateComment(opportunityId: String, commentId: String, newText: String) async throws {
        let ref = commentsRef(opportunityId).child(commentId)
        try await updateChildValues(ref: ref, values: ["text": newText])
    }

    // MARK: - DELETE

    func deleteComment(opportunityId: String, commentId: String) async throws {
        let ref = commentsRef(opportunityId).child(commentId)
        try await removeValue(ref: ref)
    }
}

// MARK: - Helpers

private extension CommentsService {

    static func asDict(_ any: Any?) -> [String: Any] {
        if let d = any as? [String: Any] { return d }
        if let ns = any as? NSDictionary {
            var out: [String: Any] = [:]
            for (k, v) in ns {
                if let ks = k as? String { out[ks] = v }
            }
            return out
        }
        return [:]
    }

    static func decodeComment(id: String, dict: [String: Any]) -> Comment? {
        guard
            let opportunityId = dict["opportunityId"] as? String,
            let authorUid = dict["authorUid"] as? String,
            let userName = dict["userName"] as? String,
            let text = dict["text"] as? String
        else { return nil }

        // ✅ createdAt может быть:
        // - ServerValue.timestamp() -> NSNumber (ms)
        // - Double/Int/String (sec or ms)
        let createdAt: TimeInterval

        if let n = dict["createdAt"] as? NSNumber {
            // Firebase server timestamp -> milliseconds
            createdAt = n.doubleValue / 1000.0
        } else if let t = dict["createdAt"] as? TimeInterval {
            createdAt = (t > 10_000_000_000 ? t / 1000.0 : t) // если вдруг ms
        } else if let d = dict["createdAt"] as? Double {
            createdAt = (d > 10_000_000_000 ? d / 1000.0 : d)
        } else if let i = dict["createdAt"] as? Int {
            let v = Double(i)
            createdAt = (v > 10_000_000_000 ? v / 1000.0 : v)
        } else if let s = dict["createdAt"] as? String, let v = Double(s) {
            createdAt = (v > 10_000_000_000 ? v / 1000.0 : v)
        } else {
            return nil
        }

        return Comment(
            id: id,
            opportunityId: opportunityId,
            authorUid: authorUid,
            userName: userName,
            text: text,
            createdAt: createdAt
        )
    }

    func setValue(ref: DatabaseReference, value: Any) async throws {
        try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, Error>) in
            ref.setValue(value) { error, _ in
                if let error { cont.resume(throwing: error) }
                else { cont.resume(returning: ()) }
            }
        }
    }

    func updateChildValues(ref: DatabaseReference, values: [AnyHashable: Any]) async throws {
        try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, Error>) in
            ref.updateChildValues(values) { error, _ in
                if let error { cont.resume(throwing: error) }
                else { cont.resume(returning: ()) }
            }
        }
    }

    func removeValue(ref: DatabaseReference) async throws {
        try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, Error>) in
            ref.removeValue { error, _ in
                if let error { cont.resume(throwing: error) }
                else { cont.resume(returning: ()) }
            }
        }
    }
}
