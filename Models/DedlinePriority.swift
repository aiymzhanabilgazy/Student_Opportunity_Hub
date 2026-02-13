import Foundation

enum DeadlinePriority {
    case critical
    case warning
    case normal
}

extension Opportunity {
    
    var daysLeft: Int {
        Calendar.current.dateComponents([.day], from: Date(), to: deadline).day ?? 0
    }
    
    var priority: DeadlinePriority {
        if daysLeft <= 3 {
            return .critical
        } else if daysLeft <= 7 {
            return .warning
        } else {
            return .normal
        }
    }
}
