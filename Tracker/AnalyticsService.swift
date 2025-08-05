import Foundation
import AppMetricaCore


struct AnalyticsService {
    static func activate() {
        guard let configuration = AppMetricaConfiguration(apiKey: "eb28b13d-a4d6-463f-8e71-25f1da4c7186") else { return }
        
        AppMetrica.activate(with: configuration)
    }
    
    func report(event: String, params : [AnyHashable : Any]) {
        AppMetrica.reportEvent(name: event, parameters: params, onFailure: { error in
            print("REPORT ERROR: %@", error.localizedDescription)
        })
    }
}
