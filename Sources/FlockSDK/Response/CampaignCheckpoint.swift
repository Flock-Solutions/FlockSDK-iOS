public enum CheckpointTrigger: String, Codable, Sendable {
    case placement
    case reward
}

public struct CampaignCheckpoint: Codable, Sendable {
    public let id: String
    public let campaignId: String
    public let checkpointName: String
    public let trigger: CheckpointTrigger
    public let placementId: String?
    public let createdAt: String
    public let updatedAt: String
}

public struct CampaignCheckpointsResponse: Codable, Sendable {
    public let data: [CampaignCheckpoint]
}
