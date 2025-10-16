import SwiftUI
import PhotosUI

struct OrganizerEventFormView: View {
    @StateObject var viewModel: OrganizerEventFormViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showImagePicker = false
    @State private var selectedPhotoItem: PhotosPickerItem?
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        imageSection
                        
                        VStack(spacing: 20) {
                            titleField
                            descriptionField
                            locationField
                            foodTypeSelector
                            dateTimeSection
                        }
                        .padding(.horizontal)
                        
                        saveButton
                            .padding(.horizontal)
                            .padding(.bottom, 32)
                    }
                    .padding(.top)
                }
            }
            .navigationTitle(viewModel.isEditMode ? "Edit Event" : "Create Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(AppColors.primaryBlue)
                }
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil), presenting: viewModel.errorMessage) { _ in
                Button("OK") {
                    viewModel.clearError()
                }
            } message: { error in
                Text(error)
            }
            .onChange(of: viewModel.showSuccess) { showSuccess in
                if showSuccess {
                    dismiss()
                }
            }
            .onChange(of: selectedPhotoItem) { newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        viewModel.selectedImage = image
                    }
                }
            }
        }
    }
    
    private var imageSection: some View {
        VStack(spacing: 12) {
            if let image = viewModel.selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 200)
                    .clipped()
                    .cornerRadius(12)
                    .padding(.horizontal)
            } else if let urlString = viewModel.existingImageUrl,
                      let url = URL(string: urlString) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(height: 200)
                            .clipped()
                            .cornerRadius(12)
                    case .failure:
                        placeholderImage
                    case .empty:
                        ProgressView()
                            .frame(height: 200)
                    @unknown default:
                        placeholderImage
                    }
                }
                .padding(.horizontal)
            } else {
                placeholderImage
                    .padding(.horizontal)
            }
            
            PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                Label(viewModel.selectedImage != nil || viewModel.existingImageUrl != nil ? "Change Photo" : "Add Photo", systemImage: "photo")
                    .font(.body)
                    .foregroundColor(AppColors.primaryBlue)
            }
        }
    }
    
    private var placeholderImage: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.gray.opacity(0.2))
            .frame(height: 200)
            .overlay(
                VStack(spacing: 8) {
                    Image(systemName: "photo")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                    Text("Optional Event Photo")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            )
    }
    
    private var titleField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Title")
                .font(.headline)
                .foregroundColor(AppColors.primaryText)
            
            TextField("Event title", text: $viewModel.title)
                .textFieldStyle(.roundedBorder)
            
            if let error = viewModel.titleError {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
    }
    
    private var descriptionField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Description")
                .font(.headline)
                .foregroundColor(AppColors.primaryText)
            
            TextEditor(text: $viewModel.description)
                .frame(height: 120)
                .padding(8)
                .background(Color.white)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
            
            if let error = viewModel.descriptionError {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
    }
    
    private var locationField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Location")
                .font(.headline)
                .foregroundColor(AppColors.primaryText)
            
            TextField("Building name, room number", text: $viewModel.location)
                .textFieldStyle(.roundedBorder)
            
            if let error = viewModel.locationError {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
    }
    
    private var foodTypeSelector: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Food Type")
                .font(.headline)
                .foregroundColor(AppColors.primaryText)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(FoodType.allCases) { type in
                        Button {
                            viewModel.foodType = type
                        } label: {
                            VStack(spacing: 4) {
                                Text(type.icon)
                                    .font(.title2)
                                Text(type.displayName)
                                    .font(.caption)
                                    .foregroundColor(viewModel.foodType == type ? .white : AppColors.primaryText)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(viewModel.foodType == type ? AppColors.primaryBlue : Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(viewModel.foodType == type ? AppColors.primaryBlue : Color.gray.opacity(0.3), lineWidth: 1)
                            )
                        }
                    }
                }
                .padding(.horizontal, 2)
            }
        }
    }
    
    private var dateTimeSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Date & Time")
                .font(.headline)
                .foregroundColor(AppColors.primaryText)
            
            VStack(spacing: 12) {
                DatePicker("Start Time", selection: $viewModel.startDate, displayedComponents: [.date, .hourAndMinute])
                    .datePickerStyle(.compact)
                
                DatePicker("End Time", selection: $viewModel.endDate, displayedComponents: [.date, .hourAndMinute])
                    .datePickerStyle(.compact)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            
            if let error = viewModel.dateError {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
    }
    
    private var saveButton: some View {
        Button {
            Task {
                await viewModel.saveEvent()
            }
        } label: {
            HStack {
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text(viewModel.isEditMode ? "Save Changes" : "Create Event")
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(AppColors.primaryBlue)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .disabled(viewModel.isLoading)
    }
}
