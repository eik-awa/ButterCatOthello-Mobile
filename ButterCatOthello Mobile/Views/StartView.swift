import SwiftUI

struct StartView: View {
    @State private var selectedMode: GameMode? = nil
    @State private var showSettings = false

    var body: some View {
        NavigationStack {
            ZStack {
                ButterBackground()

                ScrollView {
                    VStack(spacing: 32) {
                        Spacer(minLength: 40)

                        // タイトル
                        VStack(spacing: 10) {
                            Image("buttercat")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80, height: 80)
                                .shadow(color: AppTheme.amberShadow, radius: 12, y: 4)

                            Text("ButterCat Othello")
                                .font(.system(size: 30, weight: .black, design: .rounded))
                                .foregroundColor(AppTheme.boardGreenDark)

                            Text("バター猫オセロ")
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundColor(AppTheme.textMid)
                        }

                        // モード選択
                        VStack(spacing: 12) {
                            Text("モードを選択")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(AppTheme.textMid)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 4)

                            ModeButton(
                                title: "CPU（かんたん）",
                                subtitle: "まずは練習から",
                                icon: "cpu",
                                color: Color(red: 0.2, green: 0.6, blue: 1.0)
                            ) { selectedMode = .cpuEasy }

                            ModeButton(
                                title: "CPU（むずかしい）",
                                subtitle: "本気で挑もう！",
                                icon: "brain.head.profile",
                                color: Color(red: 0.8, green: 0.2, blue: 0.4)
                            ) { selectedMode = .cpuHard }
                            
                            ModeButton(
                                title: "二人で対戦",
                                subtitle: "友達と一緒に！",
                                icon: "person.2.fill",
                                color: AppTheme.boardGreen
                            ) { selectedMode = .pvp }
                        }
                        .padding(.horizontal, 24)

                        // 特殊駒説明
                        SpecialDiscLegend()
                            .padding(.horizontal, 24)
                            .padding(.bottom, 48)
                    }
                }

                // 設定ボタン（右上固定）
                VStack {
                    HStack {
                        Spacer()
                        Button { showSettings = true } label: {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(AppTheme.boardGreenDark)
                                .frame(width: 40, height: 40)
                                .background(
                                    Circle()
                                        .fill(AppTheme.card)
                                        .shadow(color: .black.opacity(0.1), radius: 6, y: 2)
                                )
                                .overlay(
                                    Circle()
                                        .stroke(AppTheme.cardBorder, lineWidth: 1.5)
                                )
                        }
                        .buttonStyle(ScaleButtonStyle())
                        .padding(.trailing, 20)
                        .padding(.top, 8)
                    }
                    Spacer()
                }
            }
            .navigationBarHidden(true)
            .navigationDestination(item: $selectedMode) { mode in
                GameView(viewModel: GameViewModel(mode: mode))
            }
            .sheet(isPresented: $showSettings) {
                SettingsSheet()
            }
        }
    }
}

// MARK: - Settings sheet
private struct SettingsSheet: View {
    @ObservedObject private var audio = AudioManager.shared
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack(spacing: 14) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(red: 0.2, green: 0.6, blue: 1.0))
                                .frame(width: 36, height: 36)
                            Image(systemName: audio.isBGMMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        Toggle("BGM", isOn: Binding(
                            get: { !audio.isBGMMuted },
                            set: { _ in audio.toggleBGM() }
                        ))
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                    }

                    HStack(spacing: 14) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(AppTheme.amber)
                                .frame(width: 36, height: 36)
                            Image(systemName: audio.isSEMuted ? "bell.slash.fill" : "bell.fill")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        Toggle("SE（効果音）", isOn: Binding(
                            get: { !audio.isSEMuted },
                            set: { _ in audio.toggleSE() }
                        ))
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                    }
                } header: {
                    Text("サウンド設定")
                }
            }
            .navigationTitle("設定")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("閉じる") { dismiss() }
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(AppTheme.boardGreenDark)
                }
            }
        }
        .presentationDetents([.medium])
    }
}

// MARK: - Mode button
private struct ModeButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void

    @State private var pressed = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(color)
                        .frame(width: 44, height: 44)
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.textDark)
                    Text(subtitle)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(AppTheme.textMid)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(AppTheme.textMid)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(AppTheme.card)
                    .shadow(color: .black.opacity(0.07), radius: 6, x: 0, y: 3)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(AppTheme.cardBorder, lineWidth: 1.5)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Special disc legend
private struct SpecialDiscLegend: View {
    struct DiscInfo { let image: String; let title: String; let lines: [String]; let bg: Color; let border: Color }
    let items = [
        DiscInfo(image: "butter",    title: "バター（トースト・小倉）",
                 lines: ["置くと相手の色になる",
                          "挟まれた相手の駒は裏返す",
                          "裏返しても360°回転して元に戻る"],
                 bg: Color(red: 1.0, green: 0.97, blue: 0.87),
                 border: Color(red: 1.0, green: 0.85, blue: 0.4)),
        DiscInfo(image: "cat",       title: "猫（白・黒）",
                 lines: ["置くと自分の色になる",
                          "自分の色で挟んでも駒を返せない",
                          "裏返しても360°回転して元に戻る"],
                 bg: Color(red: 0.92, green: 0.98, blue: 0.94),
                 border: Color(red: 0.3, green: 0.8, blue: 0.5)),
        DiscInfo(image: "buttercat", title: "バター猫（共通）",
                 lines: ["置くとY軸回転し続ける",
                          "相手でも自分でもない色扱い",
                          "バター猫駒を挟んで駒を裏返せない"],
                 bg: Color(red: 1.0, green: 0.95, blue: 0.88),
                 border: Color(red: 1.0, green: 0.7, blue: 0.3)),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("特殊駒ガイド")
                .font(.system(size: 14, weight: .black, design: .rounded))
                .foregroundColor(AppTheme.textDark)

            ForEach(items, id: \.title) { item in
                HStack(alignment: .top, spacing: 12) {
                    Image(item.image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 36, height: 36)
                        .padding(.top, 2)
                    VStack(alignment: .leading, spacing: 3) {
                        Text(item.title)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(AppTheme.textDark)
                        VStack(alignment: .leading, spacing: 1) {
                            ForEach(item.lines, id: \.self) { line in
                                Text("・\(line)")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(AppTheme.textMid)
                            }
                        }
                    }
                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(item.bg)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(item.border, lineWidth: 1.5))
                )
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(AppTheme.card.opacity(0.8))
                .overlay(RoundedRectangle(cornerRadius: 18).stroke(AppTheme.cardBorder, lineWidth: 1.5))
                .shadow(color: .black.opacity(0.06), radius: 8, y: 3)
        )
    }
}

// MARK: - Scale button style
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(duration: 0.15), value: configuration.isPressed)
    }
}

extension GameMode: Hashable {}
