#include <iostream>
#include <pthread.h>
#include <string>
#include <vector>
#include <bits/stdc++.h>

using namespace std;

const int BAKING_TIME = 2;
const int BAKER_CAPACITY = 10;

struct Bread
{
    string customer;
    int time;
};

struct Order
{
    string customer_name;
    int num_breads;
    int start_time;
    int end_time;
};

struct Summary
{
    string customer;
    int start_time;
    int end_time;
};

vector<Order> one_baker_orders()
{
    string names;
    string s;
    int num;
    vector<Order> orders;
    Order order;
    vector<string> v;

    getline(cin, names);
    stringstream ss(names);

    while (getline(ss, s, ' '))
    {
        v.push_back(s);
    }
    // cout << v.size() << endl;
    for (int i = 0; i < v.size(); i++)
    {
        // cout << v[i] << endl;
        order.customer_name = v[i];
        cin >> num;
        order.num_breads = num;
        order.start_time = -1;
        order.end_time = -1;
        orders.push_back(order);
    }
    return orders;
}

vector<Bread> baking(vector<Order> orders, vector<Order> *orders_base)
{

    Bread b;
    int oven_size;
    vector<Bread> oven;
    vector<Bread> delivary_space;
    int index = 0;
    int time = 0;
    while (orders.size() != 0)
    {
        if (orders[0].num_breads > 10)
        {
            if (orders_base->at(index).start_time == -1)
                orders_base->at(index).start_time = time;
            b.customer = orders[0].customer_name;
            b.time = time;
            for (int i = 0; i < 10; i++)
            {
                oven.push_back(b);
            }
            orders[0].num_breads -= 10;
        }
        else
        {
            if (orders_base->at(index).start_time == -1)
                orders_base->at(index).start_time = time;
            b.customer = orders[0].customer_name;
            b.time = time;
            for (int i = 0; i < orders[0].num_breads; i++)
            {
                oven.push_back(b);
            }
            if (orders_base->at(index).end_time == -1)
                orders_base->at(index).end_time = time + BAKING_TIME;
            orders.erase(orders.begin());
            index++;
        }

        time += BAKING_TIME;

        while (oven.size() != 0)
        {
            oven[0].time += 2;
            delivary_space.push_back(oven[0]);
            oven.erase(oven.begin());
        }
    }

    return delivary_space;
}

// int find_first(vector<Bread> delivary_space, string name)
// {
//     for (int i = 0; i < delivary_space.size(); i++)
//     {
//         if (name == delivary_space[i].customer)
//         {
//             return i;
//         }
//     }
// }

// int find_last(vector<Bread> delivary_space)
// {
//     int index;
//     for (int i = 0; i < delivary_space.size(); i++)
//     {
//         if (name == delivary_space[i].customer)
//         {
//             index i;
//         }
//     }
// }

int main(void)
{

    int num_bakers = 1;
    vector<Order> orders = one_baker_orders();
    // for (int i = 0; i < orders.size(); i++)
    // {
    //     cout << orders[i].customer_name << " " << orders[i].num_breads << endl;
    // }

    vector<Bread> delivary_space = baking(orders, &orders);
    for (int i = 0; i < delivary_space.size(); i++)
    {
        cout << delivary_space[i].customer << " " << delivary_space[i].time << endl;
    }

    float mean = 0;
    for (int i = 0; i < orders.size(); i++)
    {
        cout << orders[i].customer_name << " " << orders[i].num_breads << " " << orders[i].start_time << " " << orders[i].end_time << endl;
        mean += (orders[i].end_time - orders[i].start_time);
    }
    mean /= orders.size();
    cout << "mean = " << mean << endl;

    float deviation = 0;

    for (int i = 0; i < orders.size(); i++)
    {
        deviation += pow(((orders[i].end_time - orders[i].start_time) - mean), 2);
    }

    deviation /= orders.size();
    deviation = sqrt(deviation);

    cout << "deviation = " << deviation << endl;
    return 0;
}