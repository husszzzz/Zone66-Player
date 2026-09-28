import SwiftUI
import Network

class NetworkMonitor: ObservableObject {
    static let shared = NetworkMonitor()

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitorQueue")

    @Published var isConnected: Bool = true
    @Published var isCellular: Bool = false

    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = (path.status == .satisfied)
                self?.isCellular = path.isExpensive
            }
        }
        monitor.start(queue: queue)
    }

    func checkNow() {
        let currentStatus = monitor.currentPath.status
        DispatchQueue.main.async {
            self.isConnected = (currentStatus == .satisfied)
        }
    }
}

struct NoInternetView: View {
    @ObservedObject var network = NetworkMonitor.shared
    @ObservedObject var loc = LocalizationManager.shared
    @EnvironmentObject var theme: Zone66Theme
    @State private var isSpinning = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            // Subtle glowing background
            RadialGradient(
                gradient: Gradient(colors: [Color.red.opacity(0.2), Color.black]),
                center: .center,
                startRadius: 20,
                endRadius: 300
            )
            .ignoresSafeArea()

            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .fill(Color.red.opacity(0.12))
                        .frame(width: 140, height: 140)

                    Circle()
                        .stroke(Color.red.opacity(0.3), lineWidth: 2)
                        .frame(width: 160, height: 160)

                    Image(systemName: "wifi.exclamationmark")
                        .font(.system(size: 64, weight: .bold))
                        .foregroundColor(.red)
                }
                .padding(.bottom, 8)

                VStack(spacing: 10) {
                    Text(loc.tr("no_internet_title"))
                        .font(.system(size: 22, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)

                    Text(loc.tr("no_internet_desc"))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.65))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }

                Button {
                    isSpinning = true
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                    network.checkNow()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        isSpinning = false
                    }
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 16, weight: .bold))
                            .rotationEffect(.degrees(isSpinning ? 360 : 0))
                            .animation(isSpinning ? Animation.linear(duration: 0.8).repeatForever(autoreverses: false) : .default, value: isSpinning)

                        Text(loc.tr("retry"))
                            .font(.system(size: 16, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 36)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(
                            colors: [Color.red, Color.red.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(Capsule())
                    .shadow(color: Color.red.opacity(0.5), radius: 10, y: 4)
                }
                .padding(.top, 10)
            }
            .padding()
        }
    }
}
