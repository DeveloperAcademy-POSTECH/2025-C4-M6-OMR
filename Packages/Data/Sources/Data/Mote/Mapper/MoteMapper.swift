import Domain
import Foundation

public enum MoteMapper {

    // DTO → Domain
    public static func toDomain(dto: MoteDTO) -> Mote {
        Mote(
            id: dto.id,
            title: dto.title,
            content: dto.content,
            createdAt: dto.createdAt,
            location: Location(latitude: dto.latitude, longitude: dto.longitude),
            address: dto.address,
            albumCoverURL: dto.albumCoverURL,
            author: User(id: dto.authorId),
            likeCount: dto.likeCount,
            hasLiked: dto.isLiked
        )
    }

    // Entity → Domain
    public static func toDomain(entity: MoteEntity) -> Mote {
        Mote(
            id: entity.id,
            title: entity.title,
            content: entity.content,
            createdAt: entity.createdAt,
            location: Location(latitude: entity.latitude, longitude: entity.longitude),
            address: entity.address,
            albumCoverURL: entity.albumCoverURL,
            author: User(id: entity.author?.id ?? UUID()),
            likeCount: entity.likeCount,
            hasLiked: entity.isLiked
        )
    }

    // Domain → Entity
    public static func toEntity(domain: Mote) -> MoteEntity {
        MoteEntity(
            id: domain.id,
            title: domain.title,
            content: domain.content,
            createdAt: domain.createdAt,
            latitude: domain.location.latitude,
            longitude: domain.location.longitude,
            address: domain.address,
            albumCoverURL: domain.albumCoverURL,
            likeCount: domain.likeCount,
            isLiked: domain.hasLiked,
            author: nil
        )
    }
}
