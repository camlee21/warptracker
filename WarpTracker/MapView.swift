// MapView.swift

import SwiftUI

enum LinkState: Equatable {
    case idle
    case firstSelected(warpID: String)
}

struct MapView: View {
    var locationID: String
    @Binding var linkState: LinkState
    @Binding var save: Save
    @Binding var selectedLocation: String?
    @State var glowingWarpID: String? = nil
    @State var debugTapPercent: CGPoint? = nil

    let imageSize: CGSize  // actual pixel dimensions of the source image

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
        case "Coronet Peak": return "coronet_peak"
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

    // Calculate the actual rendered rect of the image within a given frame
    func renderedImageRect(in frameSize: CGSize) -> CGRect {
        let imageAspect = imageSize.width / imageSize.height
        let frameAspect = frameSize.width / frameSize.height

        let renderedSize: CGSize
        if imageAspect > frameAspect {
            // Image is wider — constrained by width
            let w = frameSize.width
            let h = w / imageAspect
            renderedSize = CGSize(width: w, height: h)
        } else {
            // Image is taller — constrained by height
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
            return warp?.linked != nil ? .green : .red
        }
    }

    func linkLabel(for warpID: String) -> String {
        guard let warp = save.graph.warps[warpID] else { return "???" }
        if let linkedID = warp.linked, let linkedWarp = save.graph.warps[linkedID] {
            return linkedWarp.location
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
              let linkedWarp = save.graph.warps[linkedID] else { return }

        selectedLocation = linkedWarp.location

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            glowingWarpID = linkedID
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                glowingWarpID = nil
            }
        }
    }

    var pointsForLocation: [WarpPoint] {
        warpPoints[locationID] ?? []
    }

    var body: some View {
        GeometryReader { geometry in
            let frameSize = geometry.size
            let imgRect = renderedImageRect(in: frameSize)

            ScrollView {
                ZStack(alignment: .topLeading) {
                    Image(getImgFromID(locationID))
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: geometry.size.height)

                    // Warp dots - positioned relative to actual image rect
                    ForEach(pointsForLocation, id: \.warpID) { point in
                        let x = imgRect.origin.x + imgRect.size.width * point.xPercent
                        let y = imgRect.origin.y + imgRect.size.height * point.yPercent

                        ZStack {
                            if glowingWarpID == point.warpID {
                                Circle()
                                    .fill(Color.white.opacity(0.6))
                                    .frame(width: 28, height: 28)
                                    .blur(radius: 6)
                            }

                            Circle()
                                .fill(dotColor(for: point.warpID))
                                .frame(width: 14, height: 14)
                                .shadow(radius: 2)
                                .animation(.easeInOut(duration: 0.3), value: glowingWarpID)

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
                    GeometryReader { imageGeometry in
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

                        // Debug tap indicator
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
                            Text(String(format: "(%.2f, %.2f)", pct.x, pct.y))
                                .font(.system(size: 9))
                                .foregroundColor(.white)
                                .padding(3)
                                .background(Color.black.opacity(0.7))
                                .cornerRadius(4)
                                .position(x: tx + 40, y: ty - 10)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    MapView(
        locationID: "Stark Mountain",
        linkState: .constant(.idle),
        save: .constant(Save(name: "Preview", date: Date(), graph: WarpGraph())),
        selectedLocation: .constant("Sandgem"),
        imageSize: CGSize(width: 800, height: 600)
    )
}
