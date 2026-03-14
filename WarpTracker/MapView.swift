// MapView.swift

import SwiftUI

enum LinkState: Equatable {
    case idle
    case firstSelected(warpID: String)
}

let iconNames = [
    "dead_end", "event", "trainer", "bike", "HM", "level", "legendary",
    "Roark", "Gardenia", "Fantina", "Maylene", "Crasher Wake", "Byron", "Candice", "Volkner",
    "Aaron", "Bertha", "Flint", "Lucian", "Cynthia"
]

let iconImageNames: [String: String] = [
    "dead_end": "dead_end",
    "event": "event",
    "trainer": "trainer",
    "bike": "Bike 2",
    "HM": "hm",
    "level": "Pokeball",
    "legendary": "MasterBall",
    "Roark": "CoalBadge",
    "Gardenia": "ForestBadge",
    "Maylene": "CobbleBadge",
    "Crasher Wake": "FenBadge",
    "Fantina": "RelicBadge",
    "Byron": "MineBadge",
    "Candice": "IcicleBadge",
    "Volkner": "BeaconBadge",
    "Aaron": "Aaron",
    "Bertha": "Bertha",
    "Flint": "Flint",
    "Lucian": "Lucian",
    "Cynthia": "Cynthia"
]

let terminalIcons = ["dead_end", "event", "legendary", "Roark", "Gardenia", "Fantina", "Maylene", "Crasher Wake", "Byron", "Candice", "Volkner", "Aaron", "Bertha", "Flint", "Lucian", "Cynthia"]

// Set to true to show percentage grid overlay for warp placement
let debugGridEnabled = false

struct MapView: View {
    var locationID: String
    @Binding var linkState: LinkState
    @Binding var save: Save
    @Binding var selectedLocation: String?
    @State var glowingWarpID: String? = nil
    @State var debugTapPercent: CGPoint? = nil
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero

    let minScale: CGFloat = 1.0
    let maxScale: CGFloat = 5.0
    let imageSize: CGSize

    func getImgFromID(_ id: String) -> String {
        switch id {
        case "Verity Lakefront": return "verity_lakefront"
        case "Lake Verity": return "lake_verity"
        case "Lake Valor": return "lake_valor"
        case "Lake Acuity": return "lake_acuity"
        case "Sandgem": return "sandgem"
        case "Jubilife": return "jubilife"
        case "Jubilife GTS": return "jubilife_gts"
        case "Route 204": return "route_204"
        case "Route 203": return "route_203"
        case "Oreburgh": return "oreburgh"
        case "Oreburgh Gate": return "oreburgh_gate"
        case "Floaroma": return "floaroma"
        case "Floaroma Meadow": return "floaroma_meadow"
        case "Valley Windworks": return "valley_windworks"
        case "Eterna": return "eterna"
        case "Eterna Forest": return "eterna_forest"
        case "Hearthome": return "hearthome"
        case "Solaceon": return "solaceon"
        case "Solaceon Ruins": return "solaceon_ruins"
        case "Veilstone": return "veilstone"
        case "Dept Store": return "dept"
        case "Pastoria": return "pastoria"
        case "Celestic": return "celestic"
        case "Canalave": return "canalave"
        case "Iron Island": return "iron_island"
        case "Snowpoint": return "snowpoint"
        case "Sunyshore": return "sunyshore"
        case "Valor Lakefront": return "valor_lakefront"
        case "Route 209": return "route_209"
        case "Route 210": return "route_210"
        case "Route 211": return "route_211"
        case "Route 212": return "route_212"
        case "Route 213": return "route_213"
        case "Route 214": return "route_214"
        case "Route 215": return "route_215"
        case "Route 216": return "route_216"
        case "Route 217": return "route_217"
        case "Route 221": return "route_221"
        case "Route 222": return "route_222"
        case "Route 205": return "route_205"
        case "Route 206": return "route_206"
        case "Route 207": return "route_207"
        case "Route 208": return "route_208"
        case "Route 223": return "route_223"
        case "Route 226": return "route_226"
        case "Route 227": return "route_227"
        case "Stark Mountain": return "stark_mountain"
        case "Route 228": return "route_228"
        case "Backlot Mansion": return "mansion"
        case "Jubilife TV": return "jubilife_tv"
        case "Poketch": return "poketch"
        case "TG Eterna": return "eterna_galactic"
        case "Old Chateau": return "old_chateau"
        case "Galactic HQ": return "galactic_hq"
        case "Acuity Lakefront": return "acuity_lakefront"
        case "Mt Coronet": return "coronet"
        case "Mt Coronet Peak": return "coronet_peak"
        case "Pokemon League": return "league"
        case "Pokemon League Outside": return "league_outside"
        case "Victory Road": return "victory_road"
        case "Fight Area": return "fight_area"
        case "Survival Area": return "survival_area"
        case "Resort Area": return "resort_area"
        case "Fuego Ironworks": return "fuego_ironworks"
        default: return "sandgem"
        }
    }

    func renderedImageRect(in frameSize: CGSize) -> CGRect {
        let imageAspect = imageSize.width / imageSize.height
        let frameAspect = frameSize.width / frameSize.height

        let renderedSize: CGSize
        if imageAspect > frameAspect {
            let w = frameSize.width
            let h = w / imageAspect
            renderedSize = CGSize(width: w, height: h)
        } else {
            let h = frameSize.height
            let w = h * imageAspect
            renderedSize = CGSize(width: w, height: h)
        }

        let xOffset = (frameSize.width - renderedSize.width) / 2
        let yOffset = (frameSize.height - renderedSize.height) / 2
        return CGRect(origin: CGPoint(x: xOffset, y: yOffset), size: renderedSize)
    }

    func dotColor(for warpID: String) -> Color {
        if glowingWarpID == warpID { return .white }
        switch linkState {
        case .firstSelected(let id) where id == warpID: return .yellow
        default:
            let warp = save.graph.warps[warpID]
            let isAvailable = save.available.contains(warpID)
            if warp?.linked != nil {
                return isAvailable ? .green : .gray
            } else {
                return isAvailable ? .red : .gray
            }
        }
    }

    func linkLabel(for warpID: String) -> String {
        guard let warp = save.graph.warps[warpID] else { return "???" }
        if let linkedID = warp.linked {
            if iconNames.contains(linkedID) {
                // Use a display name map to preserve casing like "HM", "Dead End" etc.
                let displayNames: [String: String] = [
                    "dead_end": "Dead End",
                    "event": "Event",
                    "trainer": "Trainer",
                    "bike": "Bike",
                    "HM": "HM",
                    "level": "Level",
                    "legendary": "Legendary",
                    "Roark": "Roark",
                    "Gardenia": "Gardenia",
                    "Fantina": "Fantina",
                    "Maylene": "Maylene",
                    "Crasher Wake": "Crasher Wake",
                    "Byron": "Byron",
                    "Candice": "Candice",
                    "Volkner": "Volkner",
                    "Aaron": "Aaron",
                    "Bertha": "Bertha",
                    "Flint": "Flint",
                    "Lucian": "Lucian",
                    "Cynthia": "Cynthia"
                ]
                return displayNames[linkedID] ?? linkedID
            }
            if let linkedWarp = save.graph.warps[linkedID] {
                let customLabels: [String: String] = [
                    // PC exits — show "X PC" instead of city name
                    "Sandgem_Centre_Exit": "Sandgem PC",
                    "Jubilife_Centre_Exit": "Jubilife PC",
                    "Oreburgh_Centre_Exit": "Oreburgh PC",
                    "Floaroma_Centre_Exit": "Floaroma PC",
                    "Eterna_Centre_Exit": "Eterna PC",
                    "Hearthome_Centre_Exit": "Hearthome PC",
                    "Solaceon_Centre_Exit": "Solaceon PC",
                    "Veilstone_Centre_Exit": "Veilstone PC",
                    "Pastoria_Centre_Exit": "Pastoria PC",
                    "Celestic_Centre_Exit": "Celestic PC",
                    "Canalave_Centre_Exit": "Canalave PC",
                    "Snowpoint_Centre_Exit": "Snowpoint PC",
                    "Sunyshore_Centre_Exit": "Sunyshore PC",
                    "Fight_Area_Centre_Exit": "Fight Area PC",
                    "Survival_Area_Centre_Exit": "Survival Area PC",
                    "Resort_Area_Centre_Exit": "Resort Area PC",
                    "League_Centre_Small_Exit": "League PC",
                    // PC left/right counters if used
                    "Sandgem_Centre_Left": "Sandgem PC",
                    "Sandgem_Centre_Right": "Sandgem PC",
                    "Jubilife_Centre_Left": "Jubilife PC",
                    "Jubilife_Centre_Right": "Jubilife PC",
                    "Oreburgh_Centre_Left": "Oreburgh PC",
                    "Oreburgh_Centre_Right": "Oreburgh PC",
                    "Floaroma_Centre_Left": "Floaroma PC",
                    "Floaroma_Centre_Right": "Floaroma PC",
                    "Eterna_Centre_Left": "Eterna PC",
                    "Eterna_Centre_Right": "Eterna PC",
                    "Hearthome_Centre_Left": "Hearthome PC",
                    "Hearthome_Centre_Right": "Hearthome PC",
                    "Solaceon_Centre_Left": "Solaceon PC",
                    "Solaceon_Centre_Right": "Solaceon PC",
                    "Veilstone_Centre_Left": "Veilstone PC",
                    "Veilstone_Centre_Right": "Veilstone PC",
                    "Pastoria_Centre_Left": "Pastoria PC",
                    "Pastoria_Centre_Right": "Pastoria PC",
                    "Celestic_Centre_Left": "Celestic PC",
                    "Celestic_Centre_Right": "Celestic PC",
                    "Canalave_Centre_Left": "Canalave PC",
                    "Canalave_Centre_Right": "Canalave PC",
                    "Snowpoint_Centre_Left": "Snowpoint PC",
                    "Snowpoint_Centre_Right": "Snowpoint PC",
                    "Sunyshore_Centre_Left": "Sunyshore PC",
                    "Sunyshore_Centre_Right": "Sunyshore PC",
                    "Fight_Area_Centre_Left": "Fight Area PC",
                    "Fight_Area_Centre_Right": "Fight Area PC",
                    "Survival_Area_Centre_Left": "Survival Area PC",
                    "Survival_Area_Centre_Right": "Survival Area PC",
                    "Resort_Area_Centre_Left": "Resort Area PC",
                    "Resort_Area_Centre_Right": "Resort Area PC",
                ]
                return customLabels[linkedID] ?? linkedWarp.location
            }
        }
        return "???"
    }

    func handleWarpTap(_ warpID: String) {
        switch linkState {
        case .idle:
            linkState = .firstSelected(warpID: warpID)
        case .firstSelected(let firstID):
            if firstID == warpID {
                linkState = .idle
            } else {
                save.graph.userLink(between: firstID, and: warpID)
                save.reloadFlags()
                linkState = .idle
            }
        }
    }

    func handleWarpLongPress(_ warpID: String) {
        guard let warp = save.graph.warps[warpID],
              let linkedID = warp.linked,
              !iconNames.contains(linkedID),
              let linkedWarp = save.graph.warps[linkedID] else { return }

        selectedLocation = linkedWarp.location

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            glowingWarpID = linkedID
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                glowingWarpID = nil
            }
        }
    }

    func clampedOffset(_ proposedOffset: CGSize, scale: CGFloat, frameSize: CGSize) -> CGSize {
        let maxX = frameSize.width * (scale - 1) / 2
        let maxY = frameSize.height * (scale - 1) / 2
        return CGSize(
            width: min(max(proposedOffset.width, -maxX), maxX),
            height: min(max(proposedOffset.height, -maxY), maxY)
        )
    }

    var pointsForLocation: [WarpPoint] {
        warpPoints[locationID] ?? []
    }

    var body: some View {
        GeometryReader { geometry in
            let frameSize = geometry.size
            let imgRect = renderedImageRect(in: frameSize)

            ZStack(alignment: .topLeading) {
                Image(getImgFromID(locationID))
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: geometry.size.height)

                // Warp dots
                ForEach(pointsForLocation, id: \.warpID) { point in
                    let x = imgRect.origin.x + imgRect.size.width * point.xPercent
                    let y = imgRect.origin.y + imgRect.size.height * point.yPercent

                    let linkedID = save.graph.warps[point.warpID]?.linked
                    let isIcon = linkedID != nil && iconNames.contains(linkedID!)

                    ZStack {
                        if glowingWarpID == point.warpID {
                            Circle()
                                .fill(Color.white.opacity(0.6))
                                .frame(width: 28, height: 28)
                                .blur(radius: 6)
                        }

                        if isIcon, let imgName = iconImageNames[linkedID!] {
                            Image(imgName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .shadow(radius: 2)
                        } else {
                            Circle()
                                .fill(dotColor(for: point.warpID))
                                .frame(width: 14, height: 14)
                                .shadow(radius: 2)
                                .animation(.easeInOut(duration: 0.3), value: glowingWarpID)
                        }

                        Text(linkLabel(for: point.warpID))
                            .font(.system(size: 8))
                            .foregroundColor(.white)
                            .padding(3)
                            .background(Color.black.opacity(0.6))
                            .cornerRadius(4)
                            .offset(y: -18)
                    }
                    .position(x: x, y: y)
                    .onTapGesture { handleWarpTap(point.warpID) }
                    .onLongPressGesture(minimumDuration: 1.0) { handleWarpLongPress(point.warpID) }
                }

                // Debug grid
                if debugGridEnabled {
                    GeometryReader { _ in
                        let w = imgRect.size.width
                        let h = imgRect.size.height
                        let ox = imgRect.origin.x
                        let oy = imgRect.origin.y

                        ForEach(1..<10) { i in
                            let xPos = ox + w * Double(i) / 10.0
                            let yPos = oy + h * Double(i) / 10.0

                            Path { path in
                                path.move(to: CGPoint(x: xPos, y: oy))
                                path.addLine(to: CGPoint(x: xPos, y: oy + h))
                            }
                            .stroke(Color.white.opacity(0.4), lineWidth: 1)

                            Path { path in
                                path.move(to: CGPoint(x: ox, y: yPos))
                                path.addLine(to: CGPoint(x: ox + w, y: yPos))
                            }
                            .stroke(Color.white.opacity(0.4), lineWidth: 1)

                            Text("\(i * 10)%")
                                .font(.system(size: 7))
                                .foregroundColor(.white)
                                .background(Color.black.opacity(0.5))
                                .position(x: xPos, y: oy + 8)

                            Text("\(i * 10)%")
                                .font(.system(size: 7))
                                .foregroundColor(.white)
                                .background(Color.black.opacity(0.5))
                                .position(x: ox + 16, y: yPos)
                        }

                        Color.clear
                            .contentShape(Rectangle())
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onEnded { value in
                                        let tapX = value.location.x
                                        let tapY = value.location.y
                                        let xPct = (tapX - imgRect.origin.x) / imgRect.size.width
                                        let yPct = (tapY - imgRect.origin.y) / imgRect.size.height
                                        debugTapPercent = CGPoint(x: xPct, y: yPct)
                                        print("Tapped: xPercent: \(String(format: "%.3f", xPct)), yPercent: \(String(format: "%.3f", yPct))")
                                    }
                            )

                        if let pct = debugTapPercent {
                            let tx = imgRect.origin.x + pct.x * imgRect.size.width
                            let ty = imgRect.origin.y + pct.y * imgRect.size.height
                            Circle()
                                .fill(Color.cyan)
                                .frame(width: 10, height: 10)
                                .position(x: tx, y: ty)
                            Text(String(format: "(%.3f, %.3f)", pct.x, pct.y))
                                .font(.system(size: 9))
                                .foregroundColor(.white)
                                .padding(3)
                                .background(Color.black.opacity(0.7))
                                .cornerRadius(4)
                                .position(x: tx + 50, y: ty - 10)
                        }
                    }
                }
            }
            .scaleEffect(scale)
            .offset(offset)
            .gesture(
                SimultaneousGesture(
                    MagnificationGesture()
                        .onChanged { value in
                            let newScale = lastScale * value
                            scale = min(max(newScale, minScale), maxScale)
                        }
                        .onEnded { _ in
                            lastScale = scale
                            if scale <= minScale {
                                withAnimation(.spring()) {
                                    scale = minScale
                                    offset = .zero
                                }
                                lastScale = minScale
                                lastOffset = .zero
                            }
                        },
                    DragGesture()
                        .onChanged { value in
                            guard scale > 1.0 else { return }
                            let newOffset = CGSize(
                                width: lastOffset.width + value.translation.width,
                                height: lastOffset.height + value.translation.height
                            )
                            offset = clampedOffset(newOffset, scale: scale, frameSize: frameSize)
                        }
                        .onEnded { _ in
                            lastOffset = offset
                        }
                )
            )
            .onChange(of: scale) { newScale in
                if newScale <= minScale {
                    withAnimation(.spring()) {
                        offset = .zero
                    }
                    lastOffset = .zero
                }
            }
            .onChange(of: locationID) { _ in
                withAnimation(.easeInOut(duration: 0.3)) {
                    scale = 1.0
                    offset = .zero
                }
                lastScale = 1.0
                lastOffset = .zero
            }
        }
        .clipped()
    }
}

#Preview {
    MapView(
        locationID: "Sandgem",
        linkState: .constant(.idle),
        save: .constant(Save(name: "Preview", date: Date(), graph: WarpGraph())),
        selectedLocation: .constant("Sandgem"),
        imageSize: CGSize(width: 800, height: 600)
    )
}
