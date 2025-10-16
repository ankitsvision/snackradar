import SwiftUI

struct OrganizerHomeView: View {
    @EnvironmentObject var sessionViewModel: SessionViewModel
    @StateObject private var viewModel: OrganizerHomeViewModel
    @State private var showCreateEvent = false
    @State private var eventToEdit: Event?
    
    init() {
        _viewModel = StateObject(wrappedValue: OrganizerHomeViewModel(organizerId: ""))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background
                    .ignoresSafeArea()
                
                if viewModel.isLoading && viewModel.events.isEmpty {
                    ProgressView()
                } else {
                    ScrollView {
                        VStack(spacing: 24) {
                            headerSection
                            
                            if viewModel.events.isEmpty {
                                emptyStateView
                            } else {
                                eventsListSection
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("My Events")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        Button {
                            showCreateEvent = true
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(AppColors.primaryBlue)
                        }
                        
                        Button {
                            sessionViewModel.signOut()
                        } label: {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .foregroundColor(AppColors.primaryBlue)
                        }
                    }
                }
            }
            .sheet(isPresented: $showCreateEvent) {
                if let profile = sessionViewModel.userProfile {
                    OrganizerEventFormView(
                        viewModel: OrganizerEventFormViewModel(
                            mode: .create,
                            organizerId: profile.uid,
                            organizerName: profile.email,
                            campusId: profile.campusId ?? ""
                        )
                    )
                }
            }
            .sheet(item: $eventToEdit) { event in
                if let profile = sessionViewModel.userProfile {
                    OrganizerEventFormView(
                        viewModel: OrganizerEventFormViewModel(
                            mode: .edit(event),
                            organizerId: profile.uid,
                            organizerName: profile.email,
                            campusId: profile.campusId ?? ""
                        )
                    )
                }
            }
            .alert("Delete Event", isPresented: $viewModel.showDeleteConfirmation) {
                Button("Cancel", role: .cancel) {
                    viewModel.cancelDelete()
                }
                Button("Delete", role: .destructive) {
                    Task {
                        await viewModel.deleteEvent()
                    }
                }
            } message: {
                Text("Are you sure you want to delete this event? This action cannot be undone.")
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil), presenting: viewModel.errorMessage) { _ in
                Button("OK") {
                    viewModel.clearError()
                }
            } message: { error in
                Text(error)
            }
            .task {
                if let profile = sessionViewModel.userProfile {
                    let newViewModel = OrganizerHomeViewModel(organizerId: profile.uid)
                    _viewModel.wrappedValue = newViewModel
                    await newViewModel.loadEvents()
                }
            }
            .refreshable {
                await viewModel.loadEvents()
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            if let profile = sessionViewModel.userProfile {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(profile.email)
                            .font(.subheadline)
                            .foregroundColor(AppColors.secondaryText)
                        
                        if profile.isApproved {
                            HStack {
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundColor(.green)
                                Text("Verified Organizer")
                                    .font(.caption)
                                    .foregroundColor(.green)
                            }
                        }
                    }
                    
                    Spacer()
                }
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 80))
                .foregroundColor(AppColors.secondaryYellow)
            
            Text("No Events Yet")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(AppColors.primaryText)
            
            Text("Create your first event to get started")
                .font(.body)
                .foregroundColor(AppColors.secondaryText)
                .multilineTextAlignment(.center)
            
            Button {
                showCreateEvent = true
            } label: {
                Text("Create Event")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
                    .background(AppColors.primaryBlue)
                    .cornerRadius(12)
            }
            
            Spacer()
        }
        .padding()
    }
    
    private var eventsListSection: some View {
        VStack(spacing: 20) {
            if !viewModel.liveEvents.isEmpty {
                eventSection(title: "Live Events", events: viewModel.liveEvents, statusColor: .green)
            }
            
            if !viewModel.upcomingEvents.isEmpty {
                eventSection(title: "Upcoming Events", events: viewModel.upcomingEvents, statusColor: AppColors.primaryBlue)
            }
            
            if !viewModel.expiredEvents.isEmpty {
                eventSection(title: "Past Events", events: viewModel.expiredEvents, statusColor: .gray)
            }
        }
    }
    
    private func eventSection(title: String, events: [Event], statusColor: Color) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(AppColors.primaryText)
            
            ForEach(events) { event in
                EventCard(
                    event: event,
                    statusColor: statusColor,
                    onEdit: {
                        eventToEdit = event
                    },
                    onDelete: {
                        viewModel.confirmDelete(event)
                    }
                )
            }
        }
    }
}

struct EventCard: View {
    let event: Event
    let statusColor: Color
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(event.foodType.icon)
                            .font(.title2)
                        
                        Text(event.title)
                            .font(.headline)
                            .foregroundColor(AppColors.primaryText)
                        
                        Spacer()
                        
                        statusBadge
                    }
                    
                    Text(event.description)
                        .font(.subheadline)
                        .foregroundColor(AppColors.secondaryText)
                        .lineLimit(2)
                    
                    HStack(spacing: 16) {
                        Label(event.location, systemImage: "location.fill")
                            .font(.caption)
                            .foregroundColor(AppColors.secondaryText)
                        
                        Label(formatDate(event.startTime), systemImage: "clock.fill")
                            .font(.caption)
                            .foregroundColor(AppColors.secondaryText)
                    }
                    
                    if !event.isApproved {
                        HStack {
                            Image(systemName: "clock.badge.exclamationmark")
                                .foregroundColor(.orange)
                            Text("Pending Approval")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
            }
            
            HStack(spacing: 12) {
                Button(action: onEdit) {
                    Label("Edit", systemImage: "pencil")
                        .font(.subheadline)
                        .foregroundColor(AppColors.primaryBlue)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(AppColors.primaryBlue.opacity(0.1))
                        .cornerRadius(8)
                }
                
                Button(action: onDelete) {
                    Label("Delete", systemImage: "trash")
                        .font(.subheadline)
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private var statusBadge: some View {
        Text(event.status.displayName)
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(statusColor)
            .cornerRadius(8)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, h:mm a"
        return formatter.string(from: date)
    }
}

struct OrganizerHomeView_Previews: PreviewProvider {
    static var previews: some View {
        OrganizerHomeView()
            .environmentObject(SessionViewModel())
    }
}
