import DataModel
import Foundation

extension SyncTask {
    func changedPodcasts() -> [Api_Record]? {
        let podcastsToSync = DataManager.sharedManager.allUnsyncedPodcasts()

        if podcastsToSync.count == 0 { return nil }

        var podcastRecords = [Api_Record]()
        for podcast in podcastsToSync {
            var podcastRecord = Api_SyncUserPodcast()
            podcastRecord.autoStartFrom.value = podcast.startFrom
            podcastRecord.autoSkipLast.value = podcast.skipLast
            podcastRecord.uuid = podcast.uuid
            podcastRecord.isDeleted.value = !podcast.isSubscribed()
            podcastRecord.subscribed.value = podcast.isSubscribed()

            var apiRecord = Api_Record()
            apiRecord.podcast = podcastRecord
            podcastRecords.append(apiRecord)
        }

        return podcastRecords
    }

    func changedEpisodes(for episodesToSync: [Episode]) -> [Api_Record]? {
        if episodesToSync.count == 0 { return nil }

        var episodeRecords = [Api_Record]()
        for episode in episodesToSync {
            var episodeRecord = Api_SyncUserEpisode()
            episodeRecord.podcastUuid = episode.podcastUuid
            episodeRecord.uuid = episode.uuid

            if episode.playingStatusModified > 0 {
                episodeRecord.playingStatus.value = episode.playingStatus
                episodeRecord.playingStatusModified.value = episode.playingStatusModified
            }
            if episode.keepEpisodeModified > 0 {
                episodeRecord.starred.value = episode.keepEpisode
                episodeRecord.starredModified.value = episode.keepEpisodeModified
            }
            if episode.playedUpToModified > 0 {
                episodeRecord.playedUpTo.value = Int64(episode.playedUpTo)
                episodeRecord.playedUpToModified.value = episode.playedUpToModified
            }
            if episode.durationModified > 0, episode.duration > 0 {
                episodeRecord.duration.value = Int64(episode.duration)
                episodeRecord.durationModified.value = episode.durationModified
            }
            if episode.archivedModified > 0 {
                episodeRecord.isDeleted.value = episode.archived
                episodeRecord.isDeletedModified.value = episode.archivedModified
            }

            var apiRecord = Api_Record()
            apiRecord.episode = episodeRecord
            episodeRecords.append(apiRecord)
        }

        return episodeRecords
    }

    func changedFilters() -> [Api_Record]? {
        let filtersToSync = DataManager.sharedManager.allUnsyncedFilters()

        if filtersToSync.count == 0 { return nil }

        var filterRecords = [Api_Record]()
        for filter in filtersToSync {
            var filterRecord = Api_SyncUserPlaylist()
            filterRecord.allPodcasts.value = filter.podcastUuids.count == 0
            filterRecord.uuid = filter.uuid
            filterRecord.originalUuid = filter.uuid // server side this field is important, because it will remain the same case DO NOT REMOVE
            filterRecord.isDeleted.value = filter.wasDeleted
            filterRecord.title.value = filter.playlistName
            filterRecord.podcastUuids.value = filter.podcastUuids
            filterRecord.audioVideo.value = filter.filterAudioVideoType
            filterRecord.notDownloaded.value = filter.filterNotDownloaded
            filterRecord.downloaded.value = filter.filterDownloaded
            filterRecord.downloading.value = filter.filterDownloading
            filterRecord.finished.value = filter.filterFinished
            filterRecord.partiallyPlayed.value = filter.filterPartiallyPlayed
            filterRecord.unplayed.value = filter.filterUnplayed
            filterRecord.starred.value = filter.filterStarred
            filterRecord.filterHours.value = filter.filterHours
            filterRecord.sortPosition.value = filter.sortPosition
            filterRecord.sortType.value = filter.sortType
            filterRecord.iconID.value = filter.customIcon

            var apiRecord = Api_Record()
            apiRecord.playlist = filterRecord
            filterRecords.append(apiRecord)
        }

        return filterRecords
    }

    func changedStats() -> Api_Record? {
        let timeSavedDynamicSpeed = convertStat(StatsManager.shared.timeSavedDynamicSpeed())
        let totalSkippedTime = convertStat(StatsManager.shared.totalSkippedTime())
        let totalIntroSkippedTime = convertStat(StatsManager.shared.totalAutoSkippedTime())
        let timeSavedVariableSpeed = convertStat(StatsManager.shared.timeSavedVariableSpeed())
        let totalListeningTime = convertStat(StatsManager.shared.totalListeningTime())
        let startSyncTime = Int64(StatsManager.shared.statsStartDate().timeIntervalSince1970)

        // check to see if there's actually any stats we need to sync
        if StatsManager.shared.syncStatus() != .notSynced || (timeSavedDynamicSpeed == nil && totalSkippedTime == nil && totalSkippedTime == nil && timeSavedVariableSpeed == nil && totalListeningTime == nil) {
            return nil
        }

        var deviceRecord = Api_SyncUserDevice()
        deviceRecord.timeSilenceRemoval.value = timeSavedDynamicSpeed ?? 0
        deviceRecord.timeSkipping.value = totalSkippedTime ?? 0
        deviceRecord.timeIntroSkipping.value = totalIntroSkippedTime ?? 0
        deviceRecord.timeVariableSpeed.value = timeSavedVariableSpeed ?? 0
        deviceRecord.timeListened.value = totalListeningTime ?? 0
        deviceRecord.timesStartedAt.value = startSyncTime
        deviceRecord.deviceID.value = Settings.uniqueAppId() ?? ""
        deviceRecord.deviceType.value = Constants.Values.deviceTypeiOS

        var apiRecord = Api_Record()
        apiRecord.device = deviceRecord

        return apiRecord
    }

    private func convertStat(_ stat: TimeInterval) -> Int64? {
        if stat < 1 { return nil }

        return Int64(stat)
    }
}
