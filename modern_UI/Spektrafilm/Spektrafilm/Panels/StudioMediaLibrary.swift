// SpektraLab Studio — media library browser.
// This view displays the persistent catalog without decoding every RAW.
import AppKit
import SwiftUI

struct StudioMediaLibrary: View {
    @Bindable var session: Session
    @Environment(\.dismiss) private var dismiss
    @State private var filter: MediaFilter = .all

    private enum MediaFilter: String, CaseIterable, Identifiable {
        case all = "All"
        case edited = "Edited"
        case untouched = "Unedited"
        var id: String { rawValue }
    }

    private var visibleFrames: [Frame] {
        session.frames.filter { frame in
            switch filter {
            case .all: return true
            case .edited: return session.editedFrames.contains(frame.id)
            case .untouched: return !session.editedFrames.contains(frame.id)
            }
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Label("Media Library", systemImage: "square.grid.2x2")
                    .font(.title2.bold())
                Spacer()
                Text("\(session.frames.count) photos")
                    .foregroundStyle(.secondary)
                Button("Add Photos…") { session.openPanel() }
                Button("Done") { dismiss() }
            }
            Picker("Filter", selection: $filter) {
                ForEach(MediaFilter.allCases) { item in
                    Text(item.rawValue).tag(item)
                }
            }
            .pickerStyle(.segmented)
            .frame(maxWidth: 340)
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 142), spacing: 14)],
                          spacing: 18) {
                    ForEach(visibleFrames) { frame in
                        Button {
                            session.click(frame.id)
                            dismiss()
                        } label: {
                            VStack(alignment: .leading, spacing: 5) {
                                CropMaskedThumbnail(
                                    url: frame.id,
                                    geometry: session.thumbnailGeometry(for: frame.id)
                                ) { image in
                                    ZStack(alignment: .bottomTrailing) {
                                        if let image {
                                            Image(decorative: image, scale: 1)
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                        } else {
                                            Rectangle().fill(.gray.opacity(0.16))
                                                .overlay(Image(systemName: "photo"))
                                        }
                                        if session.editedFrames.contains(frame.id) {
                                            Text("Edited")
                                                .font(.caption2.bold())
                                                .padding(4)
                                                .background(.black.opacity(0.8))
                                                .foregroundStyle(.white)
                                        }
                                    }
                                    .frame(height: 115)
                                }
                                Text(frame.name).lineLimit(1)
                                    .font(.caption)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }.padding(10)
            }
            if visibleFrames.isEmpty {
                Text("No photos in this filter.")
                    .foregroundStyle(.secondary)
            }
        }
        .padding(18)
        .frame(minWidth: 650, minHeight: 470)
    }
}
