enum FoodType: String, Codable, CaseIterable {
    // Fruits
    case apple = "🍎 Apple"
    case banana = "🍌 Banana"
    case pear = "🍐 Pear"
    case peach = "🍑 Peach"
    case avocado = "🥑 Avocado"
    
    // Vegetables
    case carrot = "🥕 Carrot"
    case broccoli = "🥦 Broccoli"
    case potato = "🥔 Potato"
    case sweetPotato = "🍠 Sweet Potato"
    case pumpkin = "🎃 Pumpkin"
    case cucumber = "🥒 Cucumber"
    
    // Grains
    case rice = "🍚 Rice"
    case bread = "🍞 Bread"
    case pasta = "🍝 Pasta"
    case cereal = "🥣 Cereal"
    
    // Protein
    case egg = "🥚 Egg"
    case chicken = "🍗 Chicken"
    case fish = "🐟 Fish"
    case tofu = "🧊 Tofu"
    
    // Dairy
    case yogurt = "🥛 Yogurt"
    case cheese = "🧀 Cheese"
    
    // Other
    case other = "📝 Other"
    
    var category: FoodCategory {
        switch self {
        case .apple, .banana, .pear, .peach, .avocado:
            return .fruits
        case .carrot, .broccoli, .potato, .sweetPotato, .pumpkin, .cucumber:
            return .vegetables
        case .rice, .bread, .pasta, .cereal:
            return .grains
        case .egg, .chicken, .fish, .tofu:
            return .protein
        case .yogurt, .cheese:
            return .dairy
        case .other:
            return .other
        }
    }
}

enum FoodCategory: String, CaseIterable {
    case fruits = "Fruits"
    case vegetables = "Vegetables"
    case grains = "Grains"
    case protein = "Protein"
    case dairy = "Dairy"
    case other = "Other"
} 