//
//  Firestore+Extensions.swift
//  Peg Plug
//
//  Created by Christian Okeke on 4/16/25.
//


import Firebase
import FirebaseFirestore

extension Query {
    func getDocumentsWithSnapshot<T: Decodable>(as type: T.Type) async throws -> (documents: [T], lastSnapshot: DocumentSnapshot?) {
        let snapshot = try await getDocuments()
        
        let documents = try snapshot.documents.map { document in
            let data = document.data()
            var decodableData = data
            decodableData["id"] = document.documentID
            
            let jsonData = try JSONSerialization.data(withJSONObject: decodableData)
            return try JSONDecoder().decode(T.self, from: jsonData)
        }
        
        return (documents, snapshot.documents.last)
    }
}

extension DocumentReference {
    func getDocumentAs<T: Decodable>(_ type: T.Type) async throws -> T {
        let snapshot = try await getDocument()
        
        guard let data = snapshot.data() else {
            throw NSError(domain: "FirestoreError", code: 404, userInfo: [NSLocalizedDescriptionKey: "Document does not exist"])
        }
        
        var decodableData = data
        decodableData["id"] = snapshot.documentID
        
        let jsonData = try JSONSerialization.data(withJSONObject: decodableData)
        return try JSONDecoder().decode(T.self, from: jsonData)
    }
}