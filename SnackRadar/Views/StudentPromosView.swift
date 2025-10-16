import SwiftUI
import FirebaseFirestore
import Combine

struct StudentPromosView: View {
    @StateObject private var viewModel = StudentPromosViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background
                    .ignoresSafeArea()
                
                if viewModel.isLoading {
                    ProgressView()
                } else if viewModel.promos.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.promos) { promo in
                                PromoCardView(promo: promo)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Promos")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "megaphone.fill")
                .font(.system(size: 80))
                .foregroundColor(AppColors.primaryBlue.opacity(0.5))
            
            Text("No Promos Yet")
                .customFont(AppFonts.headline)
                .foregroundColor(AppColors.primaryText)
            
            Text("Check back later for promotional content from campus organizations")
                .customFont(AppFonts.body)
                .foregroundColor(AppColors.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
}

struct PromoCardView: View {
    let promo: PromoPost
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if promo.isPinned {
                HStack {
                    Image(systemName: "pin.fill")
                        .font(.caption)
                        .foregroundColor(AppColors.secondaryYellow)
                    Text("Pinned")
                        .customFont(AppFonts.caption)
                        .foregroundColor(AppColors.secondaryYellow)
                        .fontWeight(.semibold)
                    Spacer()
                }
            }
            
            if let imageUrl = promo.imageUrl, !imageUrl.isEmpty {
                AsyncImage(url: URL(string: imageUrl)) { phase in
                    switch phase {
                    case .empty:
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 180)
                            .overlay(ProgressView())
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 180)
                            .clipped()
                            .cornerRadius(8)
                    case .failure:
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 180)
                            .overlay(
                                Image(systemName: "photo")
                                    .foregroundColor(.gray)
                            )
                            .cornerRadius(8)
                    @unknown default:
                        EmptyView()
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(promo.title)
                    .customFont(AppFonts.headline)
                    .foregroundColor(AppColors.primaryText)
                
                Text(promo.content)
                    .customFont(AppFonts.body)
                    .foregroundColor(AppColors.secondaryText)
                    .lineLimit(3)
                
                HStack {
                    Text("by \(promo.organizerName)")
                        .customFont(AppFonts.caption)
                        .foregroundColor(AppColors.secondaryText)
                    
                    Spacer()
                    
                    Text(formatDate(promo.createdAt))
                        .customFont(AppFonts.caption)
                        .foregroundColor(AppColors.secondaryText)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

@MainActor
class StudentPromosViewModel: ObservableObject {
    @Published var promos: [PromoPost] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let promoRepository: PromoRepositoryProtocol
    private let campusSelectionManager = CampusSelectionManager.shared
    private var promosListener: ListenerRegistration?
    private var cancellables = Set<AnyCancellable>()
    
    init(promoRepository: PromoRepositoryProtocol = PromoRepository.shared) {
        self.promoRepository = promoRepository
        setupCampusObserver()
    }
    
    deinit {
        promosListener?.remove()
    }
    
    private func setupCampusObserver() {
        campusSelectionManager.$selectedCampusId
            .sink { [weak self] campusId in
                self?.startListeningToPromos(campusId: campusId)
            }
            .store(in: &cancellables)
    }
    
    private func startListeningToPromos(campusId: String?) {
        promosListener?.remove()
        
        guard let campusId = campusId else {
            promos = []
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        promosListener = promoRepository.listenToPromos(campusId: campusId) { [weak self] result in
            Task { @MainActor [weak self] in
                self?.isLoading = false
                switch result {
                case .success(let promos):
                    self?.promos = promos
                    self?.errorMessage = nil
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    print("Error listening to promos: \(error)")
                }
            }
        }
    }
}

struct StudentPromosView_Previews: PreviewProvider {
    static var previews: some View {
        StudentPromosView()
    }
}
