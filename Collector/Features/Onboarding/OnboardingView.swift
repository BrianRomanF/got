import SwiftUI

struct OnboardingView: View {
    let onStart: () -> Void

    var body: some View {
        ZStack {
            Image("OnboardingHero")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            LinearGradient(
                colors: [
                    Color.white.opacity(0.16),
                    Color.white.opacity(0.03),
                    ComicTheme.paper.opacity(0.94)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                VStack(spacing: 8) {
                    Text("GOT IT?")
                        .font(.custom(ComicTheme.brandFontName, size: 64, relativeTo: .largeTitle))
                        .foregroundStyle(ComicTheme.ink)
                        .lineLimit(1)
                        .minimumScaleFactor(0.65)

                    Text(L10n.Home.eyebrow.uppercased())
                        .font(.system(.headline, design: .rounded).weight(.black))
                        .foregroundStyle(ComicTheme.ink)
                        .lineLimit(1)
                        .tracking(6)
                }
                .padding(.top, 46)
                .padding(.horizontal, 24)

                Spacer()

                VStack(spacing: 16) {
                    VStack(spacing: 10) {
                        Text(L10n.Onboarding.headline)
                            .font(.system(.title, design: .rounded).weight(.black))
                            .foregroundStyle(ComicTheme.ink)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)

                        Text(L10n.Onboarding.tagline)
                            .font(.system(.body, design: .rounded).weight(.semibold))
                            .foregroundStyle(ComicTheme.ink.opacity(0.82))
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.horizontal, 18)

                    HStack(spacing: 10) {
                        Capsule()
                            .fill(ComicTheme.ink.opacity(0.22))
                            .frame(width: 42, height: 3)

                        Text(L10n.Onboarding.ownership.uppercased())
                            .font(.caption.weight(.black))
                            .foregroundStyle(ComicTheme.ink.opacity(0.66))
                            .lineLimit(1)
                            .minimumScaleFactor(0.72)

                        Capsule()
                            .fill(ComicTheme.ink.opacity(0.22))
                            .frame(width: 42, height: 3)
                    }
                    .padding(.vertical, 4)

                    Button(action: onStart) {
                        HStack {
                            Spacer(minLength: 0)
                            Text(L10n.Onboarding.start)
                            Spacer(minLength: 0)
                            Image(systemName: "chevron.right")
                        }
                        .font(.headline.weight(.black))
                        .foregroundStyle(ComicTheme.ink)
                        .padding(.vertical, 16)
                        .padding(.horizontal, 22)
                        .background(ComicTheme.yellow)
                        .overlay(
                            Capsule()
                                .stroke(ComicTheme.ink, lineWidth: 3)
                        )
                        .clipShape(Capsule())
                        .shadow(color: ComicTheme.ink, radius: 0, x: 4, y: 4)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 28)
                .padding(.bottom, 40)
            }
        }
    }
}
