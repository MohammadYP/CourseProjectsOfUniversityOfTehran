#include <iostream>
#include <queue>
#include <string>
#include <vector>
#include <cmath>
#include <pthread.h>
#include <chrono>
#include <thread>
#include <sstream>

using namespace std;
using namespace chrono;

const int MAX_BREADS_PER_OVEN = 10;
const int BAKING_TIME = 2000;
const int MAX_ORDER = 15;

struct Order {
    string name;
    int bread_count;
    long long start_time;
    long long end_time;
};

vector<queue<Order>> baker_queues;
vector<pthread_mutex_t> queue_mutexes;
vector<Order> completed_orders;
pthread_mutex_t print_mutex = PTHREAD_MUTEX_INITIALIZER;
pthread_mutex_t completed_mutex = PTHREAD_MUTEX_INITIALIZER;
pthread_mutex_t space_mutex = PTHREAD_MUTEX_INITIALIZER;
int total_oven_capacity;

void* bake_orders(void* arg) {
    int baker_id = *(int*)arg;
    while (true) {
        pthread_mutex_lock(&queue_mutexes[baker_id]);
        if (baker_queues[baker_id].empty()) {
            pthread_mutex_unlock(&queue_mutexes[baker_id]);
            break;
        }

        Order customer = baker_queues[baker_id].front();
        baker_queues[baker_id].pop();
        pthread_mutex_unlock(&queue_mutexes[baker_id]);

        customer.start_time = duration_cast<milliseconds>(steady_clock::now().time_since_epoch()).count();

        string name = customer.name;
        int bread_count = customer.bread_count;

        pthread_mutex_lock(&print_mutex);
        cout << "Baker " << baker_id + 1 << " started for " << name << " (" << bread_count << " breads)\n";
        pthread_mutex_unlock(&print_mutex);

        while (bread_count > 0) {
            pthread_mutex_lock(&space_mutex);
            int bake_now = min(bread_count, total_oven_capacity);
            total_oven_capacity -= bake_now;
            pthread_mutex_unlock(&space_mutex);

            this_thread::sleep_for(milliseconds(BAKING_TIME));

            bread_count -= bake_now;
            pthread_mutex_lock(&print_mutex);
            cout << "Baker " << baker_id + 1 << " cooked " << bake_now << " breads for " << name << endl;
            pthread_mutex_unlock(&print_mutex);

            pthread_mutex_lock(&space_mutex);
            total_oven_capacity += bake_now;
            pthread_mutex_unlock(&space_mutex);
        }

        customer.end_time = duration_cast<milliseconds>(steady_clock::now().time_since_epoch()).count();

        pthread_mutex_lock(&completed_mutex);
        completed_orders.push_back(customer);
        pthread_mutex_unlock(&completed_mutex);

        pthread_mutex_lock(&print_mutex);
        cout << "Baker " << baker_id + 1 << " completed " << name << "'s order\n";
        pthread_mutex_unlock(&print_mutex);
    }

    return nullptr;
}

void simulate_bakery(vector<vector<Order>> &orders, int num_bakers) {
    total_oven_capacity = num_bakers * MAX_BREADS_PER_OVEN;

    for (int i = 0; i < num_bakers; ++i) {
        pthread_mutex_lock(&queue_mutexes[i]);
        for (vector<Order>::const_iterator order = orders[i].begin(); order != orders[i].end(); ++order) {
            baker_queues[i].push(*order);
        }
        pthread_mutex_unlock(&queue_mutexes[i]);
    }

    pthread_t bakers[num_bakers];
    vector<int> baker_ids(num_bakers);

    for (int i = 0; i < num_bakers; ++i) {
        baker_ids[i] = i;
        pthread_create(&bakers[i], nullptr, bake_orders, &baker_ids[i]);
    }

    for (int i = 0; i < num_bakers; ++i) {
        pthread_join(bakers[i], nullptr);
    }

    cout << "All orders completed\n";

    vector<long long> completion_times;
    for (vector<Order>::const_iterator order = completed_orders.begin(); order != completed_orders.end(); ++order) {
        completion_times.push_back(order->end_time - order->start_time);
    }

    long long total_time = 0;
    for (vector<long long>::const_iterator time = completion_times.begin(); time != completion_times.end(); ++time) {
        total_time += *time;
    }
    double mean = static_cast<double>(total_time) / completion_times.size();

    double variance = 0;
    for (vector<long long>::const_iterator time = completion_times.begin(); time != completion_times.end(); ++time) {
        variance += pow(*time - mean, 2);
    }
    variance /= completion_times.size();
    double stddev = sqrt(variance);

    mean = mean / 1000;
    variance = variance / 1000000;
    stddev = stddev / 1000;
    cout << "\n\nAverage: " << mean << " s\n";
    cout << "Deviation: " << stddev << " s\n";
    cout << "Variance: " << variance << " s^2\n";
}

vector<vector<Order>> parse_input(istream &input, int num_bakers) {
    vector<vector<Order>> orders(num_bakers);
    string line;

    for (int i = 0; i < num_bakers; ++i) {
        cout << "Enter customer names for baker " << i + 1 << ": ";
        getline(input, line);
        vector<string> names;
        stringstream names_ss(line);
        string name;
        while (names_ss >> name) {
            names.push_back(name);
        }

        cout << "Enter order counts for baker " << i + 1 << ": ";
        getline(input, line);
        stringstream orders_ss(line);
        int order;
        for (size_t j = 0; j < names.size(); ++j) {
            if (!(orders_ss >> order)) {
                break;
            }

            if (order > MAX_ORDER) {
                cout << "Order for " << names[j] << " is more than max (" << MAX_ORDER << "). skipping order.\n";
            } else {
                orders[i].push_back({names[j], order});
            }
        }
    }

    return orders;
}

int main() {
    int num_bakers;
    cout << "Enter the number of bakers: ";
    cin >> num_bakers;
    cin.ignore();

    baker_queues.resize(num_bakers);
    queue_mutexes.resize(num_bakers);

    for (int i = 0; i < num_bakers; ++i) {
        pthread_mutex_init(&queue_mutexes[i], nullptr);
    }

    vector<vector<Order>> orders = parse_input(cin, num_bakers);

    simulate_bakery(orders, num_bakers);

    for (int i = 0; i < num_bakers; ++i) {
        pthread_mutex_destroy(&queue_mutexes[i]);
    }

    return 0;
}
