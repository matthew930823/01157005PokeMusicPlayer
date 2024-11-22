import SwiftUI

let Column: Int = 6
let Row: Int = 5

var point:[Color:Int] = [
    .red : 0,
    .blue : 0,
    .green : 0,
    .purple : 0,
    .clear : 0
]

let maxHP = 50
var HP = 50

struct MonsterInfo{
    let name: String
    let info: String
    let image: ImageResource
}

enum GemType: String, CaseIterable {
    case red, blue, green, purple, empty
    var color: Color {
        switch self {
        case .red: return .red
        case .blue: return .blue
        case .green: return .green
        case .purple: return .purple
        case .empty: return .clear
        }
    }
}

struct Gem: Equatable {
    var type: GemType
    var isSelected: Bool = false
    var isNew: Bool = false
    static func ==(lhs: Gem, rhs: Gem) -> Bool {
        return lhs.type == rhs.type
    }
}

struct pokeGame: View {
    @EnvironmentObject var characterAttributes: CharacterAttributes
    @StateObject var monsterAttributes = MonsterAttributes()
    @StateObject private var viewModel = BoardViewModel()
    @StateObject var timerviewModel = TimerViewModel()
    @State private var selectedGem: (Int, Int)? = nil
    
    @State private var isAnimating = false
    
    @State private var isGetPointAnimating1 = false
    @State private var isGetPointAnimating2 = false
    @State private var isGetPointAnimating3 = false
    
    @State private var isWinPageActive: Bool = false
    @State private var isLosePageActive: Bool = false
    
    @State private var isTeachScreenActive: Bool = false
    
    @State private var ismusicScreenActive: Bool = false
    @StateObject var MusicviewModel = MusicPlayerViewModel()
    
    let monsterInfo : [MonsterInfo] = [
        MonsterInfo(name: "土狼犬", info: "攻擊力：3\n血量：10\n會露出大大的獠牙不停猛叫來威嚇對手，這是牠膽小性格的表現。",image:.monster1),
        MonsterInfo(name: "無極汰那", info: "攻擊力：6\n血量：50\n會用胸部的核心吸收伽勒爾的大地湧出的能量，藉以保持自己的活力。",image:.monster2)
    ]
    @State private var isShowingInfoSheet = false
    @State private var nowMonster = 1
    
    @State private var isfireeffect = false
    @State private var iswatereffect = false
    @State private var isgrasseffect = false
    
    var body: some View {
        NavigationView {
            ZStack{
                NavigationLink(
                    destination: WinView(onRestart: { restartGame() }).environmentObject(timerviewModel),
                    isActive: $isWinPageActive
                ) {
                    EmptyView()
                }
                NavigationLink(
                    destination: LoseView(onRestart: { restartGame() }).environmentObject(timerviewModel),
                    isActive: $isLosePageActive
                ) {
                    EmptyView()
                }.onChange(of: timerviewModel.timerValue) { newValue in
                    if newValue == 0 {
                        isLosePageActive = true // 時間到，觸發頁面跳轉
                    }
                }
                Image(.fightBackground)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                
                TimerView()
                    .offset(x:-125,y:-400)
                    .environmentObject(timerviewModel)
                VStack {
                    ZStack{
                        Button(action:{
                            ismusicScreenActive = true
                        }){
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(gradient: Gradient(colors: [Color.purple, Color.blue]),
                                                       startPoint: .topLeading,
                                                       endPoint: .bottomTrailing)
                                    )
                                    .frame(width: 50, height: 50)
                                    .shadow(radius: 10)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white.opacity(0.8), lineWidth: 3)
                                    )
                                
                                Image(systemName: "music.note")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundColor(.white)
                                    .frame(width: 30, height: 30)
                            }
                        }.offset(x:150,y:-180)
                        Button(action:{
                            isTeachScreenActive = true
                        }){
                            ZStack {
                                Circle()
                                    .fill(Color.blue.opacity(0.8))
                                    .frame(width: 60, height: 60)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white, lineWidth: 3)
                                    )
                                    .shadow(radius: 5)
                                
                                Image(systemName: "questionmark.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundColor(.white)
                                    .frame(width: 35, height: 35)
                            }
                        }.offset(x:150,y:-250)
                        Button(action:{
                            isShowingInfoSheet = true
                        }){
                            ZStack{
                                MonsterView(head:"monster\(nowMonster)")
                                    .frame(width:250, height:250)
                                    .offset(y:-100)
                                    .padding(.bottom,-230)
                                    .offset(x: monsterAttributes.isShaking ? 20 : 0)
                                    .animation(.easeInOut(duration: 0.1).repeatCount(5, autoreverses: true), value: monsterAttributes.isShaking)
                                    .environmentObject(monsterAttributes)
                                if isfireeffect{
                                    ExplosionEffect()
                                        .frame(width:50, height:50)
                                        .offset(y: 150)
                                }
                                if iswatereffect{
                                    WaterEffect()
                                        .frame(width:50, height:50)
                                        .offset(y: 150)
                                }
                                if isgrasseffect{
                                    GrassEffectWithExplosion()
                                        .frame(width:50, height:50)
                                        .offset(y: 150)
                                }
                            }
                        }.offset(y:-150)
                        
                        Button(action: {
                            hit()
                            health()
                            // 停止抖動
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                monsterAttributes.isShaking = false
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                                isfireeffect = false
                                iswatereffect = false
                                isgrasseffect = false
                            }
                            
                        }){
                            Image(systemName: "flame.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .padding()
                                .background(Circle().fill(Color.red))
                                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                .shadow(radius: 5)
                        }.offset(x: 130, y: -70)
                    }
                    
                    
                    HStack{
                        ForEach(1..<4, id: \.self){ i in
                            ZStack{
                                CharacterBox(head: "head\(i)")
                                    .frame(width: 70, height: 70)
                                    .padding(.bottom, -15)
                                    .padding(.horizontal, 20)
                                    .scaleEffect(i == 1 ? (isGetPointAnimating1 ? 1.2 : 1.0) : (i == 2 ? (isGetPointAnimating2 ? 1.2 : 1.0) : (isGetPointAnimating3 ? 1.2 : 1.0)))
                                    .rotationEffect(i == 1 ? (isGetPointAnimating1 ? .degrees(10) : .degrees(0)) : (i == 2 ? (isGetPointAnimating2 ? .degrees(10) : .degrees(0)) : (isGetPointAnimating3 ? .degrees(10) : .degrees(0))))
                                    .animation(.easeInOut(duration: 0.3), value: i == 1 ? isGetPointAnimating1 : (i == 2 ? isGetPointAnimating2 : isGetPointAnimating3))
                                
                                Text(point[characterAttributes.attributes["head\(i)"]!] ?? 0 > 0 ? "\(point[characterAttributes.attributes["head\(i)"]!] ?? 0)" : " ")
                                    .font(.largeTitle)
                                    .foregroundStyle(characterAttributes.attributes["head\(i)"]!)
                                    .scaleEffect(i == 1 ? (isGetPointAnimating1 ? 2.5 : 1.0) : (i == 2 ? (isGetPointAnimating2 ? 2.5 : 1.0) : (i == 3 ? (isGetPointAnimating3 ? 2.5 : 1.0) : 1.0)))
                                    .animation(.easeInOut(duration: 0.3), value: i == 1 ? isGetPointAnimating1 : (i == 2 ? isGetPointAnimating2 : isGetPointAnimating3))
                                    .onChange(of: point[characterAttributes.attributes["head\(i)"]!]) { _ in
                                        if i == 1 {
                                            isGetPointAnimating1 = true
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                                isGetPointAnimating1 = false
                                            }
                                        } else if i == 2  {
                                            isGetPointAnimating2 = true
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                                isGetPointAnimating2 = false
                                            }
                                        } else if i == 3  {
                                            isGetPointAnimating3 = true
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                                isGetPointAnimating3 = false
                                            }
                                        }
                                    }
                            }
                            
                        }
                    }
                    HStack {
                        Image(.iconFairy)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                        ZStack{
                            RoundedRectangle(cornerRadius: 10)
                                .frame(width: 350, height: 15)
                                .foregroundColor(Color.gray.opacity(0.3)) // 背景色
                            
                            RoundedRectangle(cornerRadius: 10)
                                .frame(width: 350 * CGFloat(HP) / CGFloat(maxHP), height: 15)
                                .foregroundColor(CGFloat(HP) / CGFloat(maxHP) > 0.5 ? .hPpink : (CGFloat(HP) / CGFloat(maxHP) > 0.2 ? .yellow : .red))
                                .animation(.easeInOut(duration: 0.5), value: CGFloat(HP) / CGFloat(maxHP))
                            Text("\(HP) / \(maxHP)")
                                .font(.title3)
                        }
                    }.padding(.bottom,-20)
                    ZStack{
                        LazyVGrid(columns: Array(repeating: GridItem(.fixed(55)), count: Column)) {
                            ForEach(0..<Row * Column, id: \.self) { index in
                                Image(.block)
                                    .resizable()
                                    .frame(width:70, height:70)
                                    .padding(.bottom,-5)
                            }
                        }
                        LazyVGrid(columns: Array(repeating: GridItem(.fixed(55)), count: Column)) {
                            ForEach(0..<Row * Column, id: \.self) { index in
                                let row1: Int = index / Column  // 修正行的計算
                                let col: Int = index % Column
                                
                                GemView(gem: viewModel.board[row1][col])
                                    .gesture(
                                        TapGesture()
                                            .onEnded { _ in
                                                handleGemTap(row: row1, col: col)
                                            }
                                    )
                                    .frame(width: 50, height: 65)
                            }
                        }
                    }
                    .padding()
                    
                    
                }
                .offset(y:100)
                .onAppear {
                    timerviewModel.startTimer()
                    viewModel.resetBoard()
                }
                .onChange(of: viewModel.board) { _ in
                    // 在每次棋盤更新時檢查並消除連線
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        viewModel.eliminateMatches()
                    }
                }
            }
            .frame(width: 300.0)
            .sheet(isPresented:$isShowingInfoSheet){
                if monsterInfo[nowMonster-1] != nil{
                    InfoView(monsterInfo: monsterInfo[nowMonster-1])
                }
            }
            .sheet(isPresented:$isTeachScreenActive){
                TeachScreenView()
            }
            .sheet(isPresented:$ismusicScreenActive){
                SongsListView(viewModel: MusicviewModel)
            }
        }
    }
    
    func handleGemTap(row: Int, col: Int) {
        
        if let selected = selectedGem {
            
            // 交換珠子並執行動畫
            withAnimation {
                viewModel.swapGem(from: selected, to: (row, col))
                isAnimating = true
            }
            selectedGem = nil
        } else {
            selectedGem = (row, col)
        }
    }
    func hit(){
        var totaldamage:Int = 0
        for (color, value) in point {
            if color == .red || color == .green || color == .blue{
                totaldamage += value
                point[color] = 0
            }
            if (color == .red && value > 0){
                isfireeffect = true
            }
            if (color == .green && value > 0){
                isgrasseffect = true
            }
            if (color == .blue && value > 0){
                iswatereffect = true
            }
        }
        monsterAttributes.applyDamage(to: "monster\(nowMonster)", damage: totaldamage)
        if totaldamage > 0{
            monsterAttributes.isShaking = true // 開始抖動
        }
        let monsterHP = monsterAttributes.getMonsterHP(for: "monster\(nowMonster)")!
        if monsterHP == 0{
            if nowMonster == 2{
                timerviewModel.stopTimer()
                isWinPageActive = true
            }
            else{
                nowMonster = 2//到下一隻
            }
        }
        else{
            hurt()
        }
    }
    func health(){
        HP = min(maxHP,HP+point[.purple]!)
        point[.purple] = 0
    }
    func hurt(){
        let power:Int=monsterAttributes.getMonsterPower(for: "monster\(nowMonster)")!
        HP = max(0,HP-power)
        if HP == 0{
            timerviewModel.stopTimer()
            isLosePageActive = true
        }
    }
    func restartGame(){
        // 重置遊戲狀態
        HP = maxHP
        nowMonster = 1
        monsterAttributes.reset()
        isWinPageActive = false
        isLosePageActive = false
        timerviewModel.resetTimer()
        timerviewModel.startTimer() // 重啟計時器
    }
}

struct TeachScreenView: View {
    
    var body: some View {
        ZStack{
            Image(.teachscreen)
                .resizable()
                .offset(x:-10)
                .scaledToFill()
                .ignoresSafeArea(.all)
        }
        
    }
}

struct InfoView: View {
    let monsterInfo: MonsterInfo
    
    var body: some View {
        ZStack{
            Image(.infobg)
                .resizable()
                .scaledToFill()
                .opacity(0.2)
                .ignoresSafeArea(.all)
            VStack {
                Image(monsterInfo.image)
                    .resizable()
                    .scaledToFit()
                Text(monsterInfo.name)
                    .font(.largeTitle)
                    .padding()
                Text(monsterInfo.info)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding()
                
            }.background(Color.gray.opacity(0.2))
        }
        
    }
}

struct GemView: View {
    var gem: Gem
    @State private var offset: CGFloat = -50  // 初始位置，代表珠子在視圖外
    
    var body: some View {
        let gemImage: String
        switch gem.type.color {
        case .red:
            gemImage = "Icon_Fire"
        case .green:
            gemImage = "Icon_Grass"
        case .blue:
            gemImage = "Icon_Water"
        case .purple:
            gemImage = "Icon_Fairy"
        default:
            gemImage = ""
        }
        
        return Image(gemImage.isEmpty ? "" : gemImage)
            .resizable()
            .scaledToFit()
            .frame(width: 50, height: 50)
            .offset(y: offset)  // 使用 offset 控制珠子的位置
            .onAppear {
                animateGem()
            }
            .onChange(of: gem) { _ in
                if gem.isNew {
                    animateGem()
                }
            }
    }
    
    private func animateGem() {
        offset = -50
        withAnimation(.easeInOut(duration: 0.5)) {
            offset = 0
        }
    }
}

class BoardViewModel: ObservableObject {
    @Published var board: [[Gem]] = []
    @EnvironmentObject var monsterAttributes: MonsterAttributes
    init() {
        resetBoard()
    }
    
    func resetBoard() {
        // 隨機生成棋盤
        board = (0..<Row).map { _ in
            (0..<Column).map { _ in
                Gem(type: GemType.allCases.filter { $0 != .empty }.randomElement()!)
            }
        }
        let matches = checkForMatches()
        let containsTrue = matches.contains(where: { row in
            row.contains(true)
        })
        if containsTrue{
            resetBoard()
        }
    }
    
    // 交換兩個格子
    func swapGem(from: (Int, Int), to: (Int, Int)) {
        point.keys.forEach { color in
            point[color] = 0
        }
        let temp = board[from.0][from.1]
        board[from.0][from.1] = board[to.0][to.1]
        board[to.0][to.1] = temp
    }
    
    // 檢查並消除連線的珠子
    func checkForMatches() -> [[Bool]] {
        var matches = Array(repeating: Array(repeating: false, count: Column), count: Row)
        
        // 檢查橫向
        for row in 0..<Row {
            for col in 0..<Column-2 { // 檢查每行的0到Column-3列
                if board[row][col].type == board[row][col+1].type && board[row][col].type == board[row][col+2].type && board[row][col].type != .empty {
                    matches[row][col] = true
                    matches[row][col+1] = true
                    matches[row][col+2] = true
                }
            }
        }
        
        // 檢查縱向
        for row in 0..<Row-2 {
            for col in 0..<Column { // 檢查每列的0到Row-3行
                if board[row][col].type == board[row+1][col].type && board[row][col].type == board[row+2][col].type && board[row][col].type != .empty {
                    matches[row][col] = true
                    matches[row+1][col] = true
                    matches[row+2][col] = true
                }
            }
        }
        return matches
    }
    
    // 消除連線並更新棋盤
    func eliminateMatches() {
        var matchesExist: Bool
        let matches = checkForMatches()
        matchesExist = false
        // 清除匹配的珠子並標記為空格
        for row in 0..<Row {
            for col in 0..<Column {
                if matches[row][col] {
                    point[board[row][col].type.color]!+=1
                    // 將匹配的珠子替換為“空格”
                    board[row][col] = Gem(type: .empty)
                    matchesExist = true
                    for i in 0..<row+1{
                        board[i][col].isNew = true
                    }
                }
            }
        }
        // 如果有珠子被清除，則進行掉落
        if matchesExist {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.dropGems()  // 處理掉落
                // 延遲後再繼續檢查是否有新的匹配
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.eliminateMatches()  // 重複檢查
                }
            }
        }
    }
    
    // 讓珠子掉落
    func dropGems() {
        for row in 0..<Row {
            for col in 0..<Column {
                board[row][col].isNew = false
            }
        }
        for col in 0..<Column {
            // 收集每列中的非空珠子
            var gemsInColumn: [Gem] = []
            
            for row in 0..<Row {
                if board[row][col].type != .empty {
                    gemsInColumn.append(board[row][col])
                }
            }
            
            // 從底部開始填充空格
            for row in (0..<Row).reversed() {
                if !gemsInColumn.isEmpty {
                    // 如果有珠子，則從底部填充珠子
                    board[row][col] = gemsInColumn.removeLast()
                } else {
                    // 如果沒有珠子可以掉落，則將其設置為空
                    board[row][col] = Gem(type: .empty)
                }
            }
            // 最上面的空格填充隨機珠子
            for row in 0..<Row {
                if board[row][col].type == .empty {
                    // 隨機生成珠子並填充到空格
                    board[row][col] = Gem(type: GemType.allCases.filter { $0 != .empty }.randomElement()!)
                }
            }
        }
        
    }
}

#Preview {
    
    var monsterAttributes = MonsterAttributes()
    var characterAttributes = CharacterAttributes()
    pokeGame().environmentObject(characterAttributes).environmentObject(monsterAttributes)
}
