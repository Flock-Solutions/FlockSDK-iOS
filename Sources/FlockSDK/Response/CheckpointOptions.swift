public struct CheckpointOptions {
    public var navigate: Bool
    public var queryParams: [String: String]?

    public init(navigate: Bool = false, queryParams: [String: String]? = nil) {
        self.navigate = navigate
        self.queryParams = queryParams
    }
}
