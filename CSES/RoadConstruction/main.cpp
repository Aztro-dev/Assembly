#include <bits/stdc++.h>

using namespace std;

// DSU that stores parents at each node, and the size of the subtree at each
// representative
class DSU {
  vector<int> cities;

public:
  DSU(int num_cities) {
    // Initialize all the cities with -1 because they are the representatives
    cities = vector<int>(num_cities, -1);
  }

  // Find the representative by going up the chain
  int get(int city) {
    if (cities[city] < 0) {
      return city;
    } else {
      return get(cities[city]);
    }
  }

  // Get the size of the subtree by negating the value of the representative
  // (which stores the size)
  int size(int city) {
    int representative = get(city);
    return -cities[representative];
  }

  // Unite the subtrees (connect the cities)
  bool unite(int city_a, int city_b) {
    // Get the representatives of each city
    int a = get(city_a);
    int b = get(city_b);

    if (a == b) {
      // They are part of the same subtree, so we don't have to do anything
      return false;
    }

    if (cities[a] > cities[b]) {
      // We want the biggest subtree to be stored in a, which is the MOST
      // negative value
      swap(a, b);
    }

    cities[a] += cities[b];
    cities[b] = a;
    return true;
  }
};

int main() {
  int cities, roads;
  cin >> cities >> roads;
  DSU dsu(cities);

  // How many independent subtrees there are
  int connected_cities = cities;
  // The size of the biggest subtree
  int biggest_connection = 1;

  while (roads-- > 0) {
    int city_a, city_b;
    cin >> city_a >> city_b;
    // This is so we don't get an out-of-bounds error
    city_a--;
    city_b--;

    if (dsu.unite(city_a, city_b)) {
      // If we are in this if statement, then the two cities were separate
      // beforehand
      connected_cities--;
      biggest_connection = max(biggest_connection, dsu.size(city_a));
    }

    cout << connected_cities << " " << biggest_connection << endl;
  }
}
