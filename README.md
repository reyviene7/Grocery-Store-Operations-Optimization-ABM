# Grocery Store Operations Optimization via Agent-Based Modeling

This project implements an agent-based model of a grocery store using NetLogo. It aims to simulate, visualize, and optimize various operational processes of a grocery environment including staffing, customer flow, inventory restocking, checkout processes, waste reduction, and queue management.

## Features

✅ Simulation of multiple store departments  
✅ Time-based staff shifts and break management  
✅ Customer shopping, queuing, and checkout behavior  
✅ Restocking and waste handling  
✅ Queue management and cashier utilization  
✅ Inventory expiry and discount mechanisms  
✅ Visualization of store operations with plots and color-coded patches  
✅ Store opening and forced closing after specified hours  
✅ Manager monitoring of busy cashiers  
✅ Support staff including cleaners, packers, stockers, produce staff, and butchers  
✅ Agent behaviors for efficient resource allocation  
✅ Dynamic reporting at store closure

## Agents

- **Customers**  
  - Enter the store at opening time  
  - Browse items and queue for checkout  
  - Seek help from produce or butcher staff  
  - Forced to exit the store at closing time

- **Cashiers**  
  - Process customer payments  
  - Go on break according to shift rules  
  - Record total sales per cashier

- **Stockers**  
  - Restock shelves during store hours and night restocking

- **Packers**  
  - Assist customers in packing purchased goods

- **Cleaners**  
  - Monitor and clean spills

- **Produce & Butcher Staff**  
  - Assist customers  
  - Monitor perishable items and apply discounts before expiry

- **Managers**  
  - Monitor overcrowded queues and deploy interventions

## Store Phases

The simulation divides store operations into logical phases:

1. **Store Preparation** — pre-opening stocking and staff arrival  
2. **Customer Journey** — browsing, queuing, and payment behavior  
3. **Core Operational Processes** — checkout, restocking, packing  
4. **Support Operations** — spills, expiry checks, break management  
5. **Closing Operations** — final restocking, closing cash registers, cleaning  

## Plots

The model includes several plots to monitor:

- Restocks vs Waste  
- Queue Length Over Time  
- Cashier Utilization  
- Payments Over Time  
- Customers in Store Over Time  
- Staff on Break Over Time

## How to Run

1. Install [NetLogo](https://ccl.northwestern.edu/netlogo/).  
2. Load the `.nlogo` file in the NetLogo GUI.  
3. Click `Setup` to initialize the store.  
4. Click `Go` to start the simulation.  
5. Observe the plots and behaviors of customers and staff agents.  
6. Adjust parameters if desired for experimentation.

## Optimization Goals

This simulation helps explore:

- Optimizing staff schedules  
- Managing queues to reduce customer abandonment  
- Balancing restocking frequency vs waste  
- Designing customer flow layouts  
- Minimizing store closure delays  

---

**Happy modeling!** 🚀  
