import Vapor
import Fluent

public extension Model {
    static func paginate(limit inLimit: Int = 10, page inPage: Int = 1, description inDescription: String = "data", filterToAdd filter:Query<Self>? = try? Self.query()) -> JSON? {
        
        guard let filter = filter else{
            return nil
        }
        guard let total = try? filter.count() else { return nil }
        let offset = inLimit * (inPage - 1)
        filter.limit = Limit(count: inLimit, offset: offset)
        guard let allItems = try? filter.run() else { return nil }
        let totalPages = (total + inLimit - 1) / inLimit
        if allItems.count == 0 { return nil }
        guard let theJsonObject = try? JSON(node:[
            inDescription: Node(node: allItems.map { try $0.makeJSON() }),
            "current_page": inPage,
            "total_pages": totalPages,
            "per_page": inLimit,
            "total": total
            ]) else { return nil }
        return theJsonObject
    }
}
