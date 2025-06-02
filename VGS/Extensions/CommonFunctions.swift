

func getCurrentTimeInMilliseconds() -> Int {
    return Int(Date().timeIntervalSince1970 * 1000)
}

func calArrivalTimeString(secondsToArrival: Int32) -> String {
    // 현재 시간에 초를 더한 도착 시간 계산
    let arrivalDate = Date().addingTimeInterval(TimeInterval(secondsToArrival))
    
    // ISO 8601 형식으로 포맷 (UTC 기준)
    let formatter = ISO8601DateFormatter()
    formatter.timeZone = TimeZone(secondsFromGMT: 0) // UTC 기준
    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    
    return formatter.string(from: arrivalDate)
}
