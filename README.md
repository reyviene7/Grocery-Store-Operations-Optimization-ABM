# Grocery Store Operations Optimization via Agent-Based Modeling

This project implements an agent-based model of a grocery store using NetLogo. It simulates, visualizes, and optimizes key operational processes such as customer flow, staffing, inventory restocking, checkout management, waste reduction, and queue handling.

## Features

✅ Simulation of multiple store departments  
✅ Time-based staff shifts and break management  
✅ Customer shopping, queuing, checkout, and exit verification  
✅ Restocking, inventory expiry, and waste handling  
✅ Discounting near-expiry items  
✅ Queue management and cashier workload optimization  
✅ Visual dashboards with real-time plots and color-coded areas  
✅ Store opening and closing protocols  
✅ Manager interventions on queue congestion  
✅ Support staff roles: cleaners, packers, stockers, produce staff, butchers  
✅ Smart agent behaviors for efficient resource allocation  
✅ End-of-day performance reports and statistics  

## Agents

- **Customers**  
  - Arrive at store opening  
  - Browse, request assistance, queue, checkout  
  - Undergo receipt verification at exit  
  - Leave store after verification or upon forced closure

- **Cashiers**  
  - Handle customer checkouts  
  - Take breaks based on shift rules  
  - Track individual and total sales

- **Packers**  
  - Bag items after cashier scanning

- **Stockers**  
  - Restock products on shelves throughout the day and at night

- **Cleaners**  
  - Clean spills and maintain safety

- **Produce & Butcher Staff**  
  - Assist customers with specific department requests  
  - Monitor and discount perishable goods

- **Managers**  
  - Monitor overcrowded queues and trigger staff responses

- **Exit Verifiers**  
  - Check customer receipts at the exit to ensure purchase validation

## Store Phases

The simulation covers a comprehensive customer journey and store lifecycle:

1. **Store Preparation**  
   - Staff arrival and shelf restocking

2. **Customer Journey**  
   - Entry → Product Selection  
   - (Optional) Department Assistance → Butcher or Produce Help  
   - Queueing → Checkout → Packing  
   - **Exit Verification**  
   - Exit

3. **Operational Processes**  
   - Cashier scanning and bagging  
   - Inventory restocking and waste handling  
   - Spill detection and cleaning  
   - Manager decision-making for crowd control  
   - Shift changes and staff breaks

4. **Closing Operations**  
   - Forced customer exit  
   - Final restock  
   - Cleanup and shutdown reporting

## Customer Path Examples

- **Full Service:**  
  `Entry → Product Selection → Department Assistance → Butcher Help → Checkout → Packing → Payment → Exit Verification → Exit`

- **Produce Help Only:**  
  `Entry → Product Selection → Department Assistance → Produce Help → Checkout → Packing → Payment → Exit Verification → Exit`

- **Quick Shop:**  
  `Entry → Product Selection → Checkout → Packing → Payment → Exit Verification → Exit`

## Plots and Metrics

Real-time monitoring of key performance indicators:

- 📦 **Restocks vs. Waste**  
- 👥 **Queue Length Over Time**  
- 💳 **Payments Processed**  
- 🧍‍♀️ **Customers in Store**  
- 😵 **Staff on Break**  
- 🧮 **Cashier Utilization**  
- ✅ **Exit Verifications Completed**  
- 📊 **Daily Sales per Cashier**  

## How to Run

1. Download and install [NetLogo](https://ccl.northwestern.edu/netlogo/).  
2. Open the `.nlogo` simulation file in the NetLogo GUI.  
3. Click `Setup` to initialize the environment.  
4. Click `Go` to begin the simulation loop.  
5. Observe agent behavior, real-time plots, and experiment with parameters.  

## Optimization Goals

Use this simulation to explore:

- Efficient staff shift and break scheduling  
- Reducing checkout queue abandonment  
- Minimizing waste while maintaining availability  
- Evaluating layout impact on customer flow  
- Verifying purchases to reduce loss prevention issues  
- Planning staffing ratios across departments  

---

**Happy modeling!** 🛒🧠  
Optimizing retail, one agent at a time.
