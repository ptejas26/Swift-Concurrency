import SwiftUI
import Combine

///https://www.youtube.com/watch?v=f2nxenwKCVM
enum CuisineType: String {
    case indian
    case japanese
    case canadian
    case thai
    case chinese
}

enum CuisineScopeOptions: Hashable {
    case all
    case cuisine(option: CuisineType)

    var title: String {
        switch self {
        case .all: return "All"
        case .cuisine(option: let option):
            return option.rawValue.capitalized
        }
    }
}

struct RestaurantModel: Identifiable, Hashable {
    let id: String
    let restaurantName: String
    let restaurantAddress: String
    let cuisine: CuisineType
}

class SearchableBootcampDataManager {


    func getData() async -> [RestaurantModel] {
        return [
            RestaurantModel(id: "1", restaurantName: "Dal dhokli", restaurantAddress: "Gol market, Gujarat", cuisine: .indian),
            RestaurantModel(id: "2", restaurantName: "Poha", restaurantAddress: "Ram nagar, Nagpur", cuisine: .indian),
            RestaurantModel(id: "3", restaurantName: "Manchurian", restaurantAddress: "Xen street, Bejing", cuisine: .chinese),
            RestaurantModel(id: "4", restaurantName: "Chickpea salad", restaurantAddress: "33 Frederick todd way, Canada", cuisine: .canadian),
            RestaurantModel(id: "5", restaurantName: "Thai Fried Rice", restaurantAddress: "344, Yen sen road", cuisine: .thai),
            RestaurantModel(id: "6", restaurantName: "Sushi", restaurantAddress: "fellow road", cuisine: .japanese),
            RestaurantModel(id: "7", restaurantName: "Maki", restaurantAddress: "ghellow road", cuisine: .japanese),
        ]
    }
}

@MainActor
class SearchableBootcampViewModel: ObservableObject {
    init() {
        addSubscriber()
    }
    var cancellableSet = Set<AnyCancellable>()
    let manager = SearchableBootcampDataManager()
    @Published var allRestaurants: [RestaurantModel] = []
    @Published var filteredRestaurants: [RestaurantModel] = []
    @Published var searchTerm: String = ""
//    @Published var searchScope: CuisineScopeOptions? = .all
    @Published var searchScope: CuisineScopeOptions = .all
//    @Published var searchScope: CuisineScopeOptions = .all
    @Published var allSearchScope: [CuisineScopeOptions] = []
    var isSearching: Bool {
        return !searchTerm.isEmpty
    }

    var showSuggestions: Bool {
        return searchTerm.count < 5
    }

    private func addSubscriber() {
        $searchTerm
            .combineLatest($searchScope)
            .debounce(for: 0.3, scheduler: DispatchQueue.main)
            .sink { [weak self] searchTerm, searchScope in

                self?.filterResults(searchTerm: searchTerm, currentSearchScope: searchScope)
            }
            .store(in: &cancellableSet)

            //        $searchScope
            //            .receive(on: DispatchQueue.main)
            //            .sink { [weak self] scopeVal in
            //                guard let searchScope = scopeVal else {
            //                    return
            //                }
            //                print(searchScope.title)
            //                if searchScope.title != "All" {
            //                    self?.filterResults(searchTerm: searchScope.title.lowercased())
            //                }
            //            }
            //            .store(in: &cancellableSet)
    }

    func filterResults(searchTerm: String, currentSearchScope: CuisineScopeOptions) {
        guard !searchTerm.isEmpty else {
            filteredRestaurants = []
            searchScope = .all
            return
        }

        var scopeSearchResult: [RestaurantModel] = allRestaurants
        // filter using search Scope
        switch currentSearchScope {
        case .all: break
        case .cuisine(option: let option):
            scopeSearchResult = allRestaurants.filter { $0.cuisine == option }
        }

        // filter using searchTerm
        filteredRestaurants = scopeSearchResult.filter { resModel in
            let addSearch = resModel.restaurantAddress.lowercased().contains(searchTerm.lowercased())
            let nameSearch = resModel.restaurantName.lowercased().contains(searchTerm.lowercased())
            let cuisineSearch = resModel.cuisine.rawValue.lowercased().contains(searchTerm.lowercased())
            return addSearch || nameSearch || cuisineSearch
        }
    }

    func loadRestaurants() {
        Task {
            allRestaurants = await manager.getData().shuffled()
            let cuisines = Set(allRestaurants.map { $0.cuisine })
            allSearchScope = [.all] + cuisines.map { CuisineScopeOptions.cuisine(option:  $0) }
        }
    }

    func getSearchSuggestion() -> [String] {

        guard showSuggestions else {
            return []
        }
        var suggestions: [String] = []

        if searchTerm.contains("Su") {
            suggestions.append("Sushi")
        }

        if searchTerm.contains("Po") {
            suggestions.append("Poha")
        }

        if searchTerm.contains("Da") {
            suggestions.append("Dal dhokli")
        }
        
        if searchTerm.contains("M") {
            suggestions.append("Maki")
        }

        if searchTerm.contains("Ch") {
            suggestions.append("Chickpea salad")
        }

        if searchTerm.contains("Th") {
            suggestions.append("Thai Fried Rice")
        }

        suggestions.append("Market")
        suggestions.append("Groceries")
        suggestions.append("Food")
        suggestions.append(CuisineType.indian.rawValue.capitalized)
        suggestions.append(CuisineType.japanese.rawValue.capitalized)
        suggestions.append(CuisineType.chinese.rawValue.capitalized)
        suggestions.append(CuisineType.canadian.rawValue.capitalized)
        suggestions.append(CuisineType.thai.rawValue.capitalized)

        return suggestions
    }

    func getRestaurantsSuggestion() -> [RestaurantModel] {

        guard showSuggestions else {
            return []
        }
        var suggestions: [RestaurantModel] = []

        if searchTerm.contains("Ind") {
            suggestions.append(contentsOf: (allRestaurants.filter { $0.cuisine == .indian }))
        }

        if searchTerm.contains("Cana") {
            suggestions.append(contentsOf: (allRestaurants.filter { $0.cuisine == .canadian }))
        }

        if searchTerm.contains("Chi") {
            suggestions.append(contentsOf: (allRestaurants.filter { $0.cuisine == .chinese }))
        }
        return suggestions
    }
}

//struct SearchableBootcampView: View {
//
//    @StateObject private var viewModel = SearchableBootcampViewModel()
//
//    var body: some View {
//        NavigationStack {
//            ScrollView {
//                VStack(spacing: 20) {
//                    ForEach(viewModel.isSearching ? viewModel.filteredRestaurants : viewModel.allRestaurants) { restaurant in
//
//                        NavigationLink(value: restaurant) {
////                            NavigationLink(destination: Text("Destination")) { /*@START_MENU_TOKEN@*/Text("Navigate")/*@END_MENU_TOKEN@*/ }
//                            searchableResultRow(restaurant: restaurant)
//                        }
//
//                    }
//                }
//                .padding()
//            }
//        }
//        .searchable(text: $viewModel.searchTerm, placement: .automatic, prompt: Text("Enter search term..."))
//        .searchScopes($viewModel.searchScope, scopes: {
//            ForEach(viewModel.allSearchScope, id: \.self) { scope in
//                Text(scope.title)
//                    .tag(scope)
//            }
//        })
//        .searchSuggestions({
//            ForEach(self.viewModel.getSearchSuggestion(), id: \.self) {
//                Text($0)
//                    .searchCompletion($0)
//            }
//        })
//        .navigationTitle("Restaurant App")
//        .task {
//            viewModel.loadRestaurants()
//        }
//        .navigationDestination(for: RestaurantModel.self) { restaurant in
//            Text(restaurant.restaurantName.uppercased())
//        }
//    }
//
//    func searchableResultRow(restaurant: RestaurantModel) -> some View {
//        VStack(alignment: .leading, spacing: 10) {
//            Text(restaurant.restaurantName)
//                .font(.title)
//                .foregroundColor(.red)
//            Text(restaurant.restaurantAddress.capitalized)
//                .font(.subheadline)
//                .fontWeight(.light)
//            Text(restaurant.cuisine.rawValue.capitalized)
//                .font(.footnote)
//                .fontWeight(.medium)
//                .foregroundColor(.blue)
//        }
//        .padding()
//        .frame(maxWidth: .infinity, alignment: .leading)
//        .background(Color.black.opacity(0.3))
//        .tint(.primary)
//    }
//}

struct SearchableBootcamp: View {

    @StateObject private var viewModel = SearchableBootcampViewModel()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(viewModel.isSearching ? viewModel.filteredRestaurants : viewModel.allRestaurants) { restaurant in
                        NavigationLink(value: restaurant, label: {
                            restaurantRow(restaurant: restaurant)
                        })
                    }
                }
                .padding()
                    //            Text("ViewModel is searching: \(viewModel.isSearching.description)")
                    //            SearchChildView()
            }
            .searchable(text: $viewModel.searchTerm, placement: .automatic, prompt: Text("Search restaurants..."))
            .searchScopes($viewModel.searchScope, scopes: {
                ForEach(viewModel.allSearchScope, id: \.self) { scope in
                    Text(scope.title)
                        .tag(scope)
                }
            })
            .searchSuggestions({
                ForEach(viewModel.getSearchSuggestion(), id: \.self) { suggestion in
                    Text(suggestion)
                        .searchCompletion(suggestion)
                }

                ForEach(viewModel.getRestaurantsSuggestion(), id: \.self) { suggestion in
                    NavigationLink(suggestion.restaurantName) {
                        restaurantRow(restaurant: suggestion)
                    }
                }
            })
            .navigationBarTitleDisplayMode(.automatic)
            .navigationTitle("Restaurants")
            .task {
                viewModel.loadRestaurants()
            }
            .navigationDestination(for: RestaurantModel.self) { restaurant in
                Text(restaurant.restaurantName.uppercased())
        }
        }
    }

    private func restaurantRow(restaurant: RestaurantModel) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(restaurant.restaurantName)
                .font(.title)
                .foregroundColor(.red)
            Text(restaurant.restaurantAddress.capitalized)
                .font(.subheadline)
                .fontWeight(.light)
            Text(restaurant.cuisine.rawValue.capitalized)
                .font(.footnote)
                .fontWeight(.medium)
                .foregroundColor(.blue)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.black.opacity(0.05))
        .tint(.primary)
    }
}

#Preview {
    NavigationStack {
        SearchableBootcamp()
    }
}
