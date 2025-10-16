import SwiftUI

struct EventCardView: View {
    let event: Event
    let remainingTime: String
    let statusBadgeColor: (background: String, text: String)
    @State private var isExpanded: Bool = false
    @State private var showReportAlert: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isExpanded.toggle()
                }
            }) {
                cardHeader
            }
            .buttonStyle(PlainButtonStyle())
            
            if isExpanded {
                expandedContent
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
        .alert("Report Event", isPresented: $showReportAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Report", role: .destructive) {
                handleReport()
            }
        } message: {
            Text("Are you sure you want to report this event as inappropriate?")
        }
    }
    
    private var cardHeader: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(event.title)
                        .customFont(AppFonts.headline)
                        .foregroundColor(AppColors.primaryText)
                        .multilineTextAlignment(.leading)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.caption)
                            .foregroundColor(AppColors.primaryBlue)
                        
                        Text(event.location)
                            .customFont(AppFonts.caption)
                            .foregroundColor(AppColors.secondaryText)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 8) {
                    statusBadge
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(AppColors.secondaryText)
                }
            }
            
            HStack {
                Image(systemName: "clock.fill")
                    .font(.caption)
                    .foregroundColor(AppColors.secondaryYellow)
                
                Text(remainingTime)
                    .customFont(AppFonts.caption)
                    .foregroundColor(AppColors.primaryText)
                    .fontWeight(.medium)
                
                Spacer()
                
                Text("by \(event.organizerName)")
                    .customFont(AppFonts.caption)
                    .foregroundColor(AppColors.secondaryText)
            }
        }
        .padding(16)
    }
    
    private var statusBadge: some View {
        Text(event.status.displayName)
            .customFont(AppFonts.caption)
            .foregroundColor(Color(hex: statusBadgeColor.text))
            .fontWeight(.semibold)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(Color(hex: statusBadgeColor.background))
            .cornerRadius(12)
    }
    
    private var expandedContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            Divider()
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Description")
                    .customFont(AppFonts.body)
                    .foregroundColor(AppColors.primaryText)
                    .fontWeight(.semibold)
                
                Text(event.description)
                    .customFont(AppFonts.body)
                    .foregroundColor(AppColors.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Time")
                    .customFont(AppFonts.body)
                    .foregroundColor(AppColors.primaryText)
                    .fontWeight(.semibold)
                
                HStack {
                    Text(formatDate(event.startTime))
                        .customFont(AppFonts.caption)
                        .foregroundColor(AppColors.secondaryText)
                    
                    Text("-")
                        .foregroundColor(AppColors.secondaryText)
                    
                    Text(formatTime(event.endTime))
                        .customFont(AppFonts.caption)
                        .foregroundColor(AppColors.secondaryText)
                }
            }
            
            if let imageUrl = event.imageUrl, !imageUrl.isEmpty {
                photoGallerySection
            }
            
            HStack(spacing: 12) {
                Button(action: openInMaps) {
                    HStack {
                        Image(systemName: "map.fill")
                        Text("Open in Maps")
                            .customFont(AppFonts.body)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(AppColors.primaryBlue)
                    .cornerRadius(8)
                }
                
                Button(action: { showReportAlert = true }) {
                    Image(systemName: "flag.fill")
                        .foregroundColor(Color.red)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                }
            }
        }
        .padding(16)
    }
    
    private var photoGallerySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Photo")
                .customFont(AppFonts.body)
                .foregroundColor(AppColors.primaryText)
                .fontWeight(.semibold)
            
            AsyncImage(url: URL(string: event.imageUrl ?? "")) { phase in
                switch phase {
                case .empty:
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 200)
                        .overlay(
                            ProgressView()
                        )
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 200)
                        .clipped()
                        .cornerRadius(8)
                case .failure:
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 200)
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
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, h:mm a"
        return formatter.string(from: date)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
    
    private func openInMaps() {
        let query = event.location.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        if let url = URL(string: "maps://?q=\(query)") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            } else if let webUrl = URL(string: "https://maps.apple.com/?q=\(query)") {
                UIApplication.shared.open(webUrl)
            }
        }
    }
    
    private func handleReport() {
        print("Report event: \(event.id)")
    }
}

struct EventCardView_Previews: PreviewProvider {
    static var previews: some View {
        EventCardView(
            event: Event(
                title: "Free Pizza in Student Center",
                description: "Free pizza available in the student center lobby. First come, first served!",
                campusId: "campus1",
                organizerId: "org1",
                organizerName: "Student Activities",
                location: "Student Center Lobby",
                startTime: Date(),
                endTime: Date().addingTimeInterval(3600),
                imageUrl: nil,
                isApproved: true
            ),
            remainingTime: "Ends in 1h 30m",
            statusBadgeColor: ("#34C759", "#FFFFFF")
        )
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
