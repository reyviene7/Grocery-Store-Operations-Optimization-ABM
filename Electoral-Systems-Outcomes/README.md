# 🌍 Election Systems ABM 🌍

## 📜 Overview
The Electoral Systems Outcomes Agent-Based Model (ABM) 🚀 is designed to simulate the impact of different voting systems on electoral outcomes within a political landscape defined by multiple policy dimensions. The model's goal is to demonstrate how identical voter populations, with consistent policy preferences and importance values, can produce divergent electoral results under various electoral systems. This project aims to underscore the significance of electoral system design on the representation of voter preferences and the formation of government policy.

## 🎯 Goals
- **Illustrate the Impact of Electoral Systems:** To show how different voting systems can lead to significantly different electoral outcomes even when voter preferences remain constant.
- **Explore Policy Representation:** To examine how well various electoral systems translate voter policy preferences into elected representation.
- **Facilitate Electoral System Comparison:** To provide a comparative analysis of majoritarian, proportional representation, and ranked-choice voting systems, among others, in terms of fairness, efficiency, and representation.

## 🌟 Significance
This project is significant as it provides insights into the mechanics of democracy and the importance of electoral system design. By understanding how different systems can affect electoral outcomes, policymakers, scholars, and the public can engage in more informed debates about electoral reform and democratic governance.

## 👥 Agent-Types
- **Voters:** Agents with distinct policy preferences and importance values across multiple policy dimensions.
- **Candidates:** Agents representing individual political figures with specific policy positions.
- **Parties:** Collective agents that aggregate candidates under unified policy positions.

## 📊 Voter Variables
For each of the five policy areas (A, B, C, D, E), voters have:
- **Policy-Importance Values:** A numeric value representing the importance of each policy area to the voter, summing to 100 across all areas.
- **Policy-Preference Values:** A value between 0 and 1 indicating the voter's preferred policy position within each area.

## 🏛️ Candidate and Party Variables
For the five policy areas, both candidates and parties have:
- **Policy Positions:** Values between 0 and 1 that define the stance of the candidate or party on each policy area.

## ⚙️ Mechanics

### Voter Decision Making
Voters choose the candidate or party that provides the highest utility, calculated as a function of the policy importance weighted by the proximity of the voter's policy preference to the candidate's or party's policy position:
- Utility = ∑ from i=A to E (Policy-Importance_i × (1 − |Policy-Preference_i − Policy-Position_i|))

## 🗳️ Voting Systems to Simulate
- **Majoritarian:** A system where the candidate with the majority of votes in a constituency wins.
- **Proportional Representation (PR):** Seats are allocated to parties based on the proportion of votes each party receives.
- **Ranked-Choice Voting (RCV):** Voters rank candidates by preference. If no candidate wins a majority of first-preference votes, the candidate with the fewest first-preference votes is eliminated, and votes are redistributed to remaining candidates based on next preferences until a candidate wins a majority.
- **Mixed-Member Proportional (MMP):** Combines elements of first-past-the-post and proportional representation, allowing voters two votes: one for a candidate and one for a party.

### Voting Mechanics: Electoral Process Dynamics
The model will simulate each electoral system's unique mechanics, including:
- **General Elections vs. Primaries:** Examining differences between primary elections, which determine party candidates, and general elections, which decide the officeholder.
- **Run-Off Elections:** Simulating scenarios where, if no candidate secures a majority in the initial vote, the top candidates face off in a second election.
- **Election Thresholds:** For proportional and mixed systems, simulating the impact of minimum vote thresholds for party representation.

This Concept of Operations document lays the groundwork for the development of the Domestic Politics ABM, outlining the model's structure, goals, and the significant impact of its findings on understanding electoral systems and democratic representation.

## Future Updates:
To evolve the Domestic Politics Agent-Based Model (ABM) into its next iteration with the new dynamics you've outlined, we're looking at a sophisticated simulation that more closely mimics the nuances of political processes and voter-politician dynamics. This enhancement focuses on three core areas: policy evolution during office tenure, adaptive behavior by both voters and politicians, and enhanced policy dynamics including external shocks. Here’s a structured approach to integrating these components:

### Policy Evolution during Office Tenure
**Mechanism:**
- Politicians propose policies while in office. The model simulates legislative sessions where these proposals are debated.
- The legislative outcome could aim for a median policy position reflecting the legislature's overall stance or maintain the status quo based on the in-office party's preference.
- Policy positions shift based on legislative outcomes, moving towards either the median legislative position, the in-office party's position, or remaining static.

**Simulation Dynamics:**
- Track policy shifts over time, reflecting the legislature's changing composition and external influences.
- Introduce a "policy impact" metric to evaluate the effectiveness and popularity of enacted policies.

### Adaptive Behavior
**Voters:**
- Update their voting preferences based on politicians' performance, with a focus on accountability and representation. This could include shifting support towards politicians or parties that have successfully enacted popular or effective policies.
- Implement a feedback loop where voter satisfaction influences future electoral choices, simulating a more dynamic electoral process.

**Politicians:**
- Adjust their policy positions based on voter feedback and legislative successes or failures, reflecting an individual learning process.
- In the legislature, implement a global learning mechanism where politicians collectively adapt their decision-making strategies based on past outcomes and future projections.

### Enhanced Policy Dynamics
**Incorporate External Shocks:**
- Simulate sudden political, economic, or social shocks (e.g., financial crises, natural disasters) and their impact on policy priorities and legislative actions.
- Model the government's response to these shocks and their subsequent effect on voter satisfaction and politician popularity.


