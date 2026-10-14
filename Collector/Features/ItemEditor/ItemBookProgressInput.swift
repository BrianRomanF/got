import SwiftUI

struct ItemBookProgressInput: View {
    @Binding var currentPage: String
    @Binding var totalPages: String
    @Binding var hasStartedAt: Bool
    @Binding var startedAt: Date
    @Binding var hasFinishedAt: Bool
    @Binding var finishedAt: Date

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(L10n.BookProgress.title.uppercased().vintageSafe)
                .font(.caption.weight(.black))
                .foregroundStyle(ComicTheme.ink.opacity(0.75))

            HStack(spacing: 10) {
                TextField("", text: $currentPage, prompt: Text(L10n.BookProgress.currentPagePlaceholder).foregroundStyle(ComicTheme.ink.opacity(0.55)))
                    .keyboardType(.numberPad)
                    .comicTextField()

                TextField("", text: $totalPages, prompt: Text(L10n.BookProgress.totalPagesPlaceholder).foregroundStyle(ComicTheme.ink.opacity(0.55)))
                    .keyboardType(.numberPad)
                    .comicTextField()
            }

            dateToggle(title: L10n.BookProgress.startedAt, isOn: $hasStartedAt, date: $startedAt)
            dateToggle(title: L10n.BookProgress.finishedAt, isOn: $hasFinishedAt, date: $finishedAt)
        }
        .padding(16)
        .comicPanel(fill: .white)
    }

    private func dateToggle(title: String, isOn: Binding<Bool>, date: Binding<Date>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Toggle(isOn: isOn) {
                Text(title.uppercased().vintageSafe)
                    .font(.caption.weight(.black))
                    .foregroundStyle(ComicTheme.red)
            }
            .tint(ComicTheme.green)

            if isOn.wrappedValue {
                DatePicker("", selection: date, displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .labelsHidden()
            }
        }
    }
}
