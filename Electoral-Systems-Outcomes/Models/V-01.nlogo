; Election Systems ABM Pseudo-Code for NetLogo
breed [voters voter]
breed [candidates candidate]
breed [partys party]

globals[
  num-voters
  num-candidates
  num-partys
  unique-state-ids
  Med-Policy-A
  Med-Policy-B
  Med-Policy-C
  Med-Policy-D
  Med-Policy-E
  Mean-Policy-A
  Mean-Policy-B
  Mean-Policy-C
  Mean-Policy-D
  Mean-Policy-E
  Legislature-Policy-A-Histogram
  national-seat-totals
  total-votes
  total-seats
  legislature-party-position-A
  legislature-party-position-B
  legislature-party-position-C
  legislature-party-position-D
  legislature-party-position-E
]


voters-own[
  policy-A-importance-values
  policy-A-preference-values
  policy-B-importance-values
  policy-B-preference-values
  policy-C-importance-values
  policy-C-preference-values
  policy-D-importance-values
  policy-D-preference-values
  policy-E-importance-values
  policy-E-preference-values
  voter-state-id
  candidate-1
  candidate-2
  candidate-3
  party-1
  party-2
  party-3
  policy-A-importance-values-01
  policy-B-importance-values-01
  policy-C-importance-values-01
  policy-D-importance-values-01
  policy-E-importance-values-01
  my-party
]

candidates-own[
  policy-A-positions
  policy-B-positions
  policy-C-positions
  policy-D-positions
  policy-E-positions
  candidate-state-id
  party-id
  party-a
;  party-b
;  party-c
  votes
  winner?
  won-primary
]

partys-own[
  party-policy-A-positions
  party-policy-B-positions
  party-policy-C-positions
  party-policy-D-positions
  party-policy-E-positions
  party-state-id
  party-mean-position
  p-votes
  party-n-id
  won-seats
  district-seat-shares
  global-party-impact-A
  global-party-impact-B
  global-party-impact-C
  global-party-impact-D
  global-party-impact-E
]

patches-own[
 state-id
 num-seats
 party-seat-shares
]

; SETUP PROCEDURES
TO setup
  clear-all
  setup-states
  setup-agents
  assign-averages
  assign-party
  reset-ticks
END

;; Divide the world into 50 states and assign unique IDs
to setup-states
  clear-all
  ; Iterate over all patches
  ask patches [
    ; Calculate the "state" based on the patch coordinates
    let state-x int(pxcor / 10)
    let state-y int(pycor / 10)
    set state-id (state-x + 10 * state-y)
    ; Assign a color based on the state
    ; This example uses a simple method to pick a color from a predefined list based on the state-id
    set pcolor item (state-id mod length base-colors) base-colors
  ]
    update-state-ids-for-patches
    set unique-state-ids remove-duplicates [state-id] of patches
    show unique-state-ids
end

to update-state-ids-for-patches
  set unique-state-ids remove-duplicates [state-id] of patches
  let sorted-state-ids sort unique-state-ids
  let id-mapping []
  let new-id 1

  foreach sorted-state-ids [
    old-id ->
    set id-mapping lput (list old-id new-id) id-mapping
    set new-id new-id + 1
  ]

  ask patches [
    let current-state-id state-id
    ; Find the new-state-id from id-mapping for current-state-id
    let new-state-id item 1 (first filter [[pair] -> first pair = current-state-id] id-mapping)
    set state-id new-state-id
  ]
end


to setup-agents
  foreach unique-state-ids [
    current-state-id ->
    ; Set the number of seats in the current state
    ask n-of 1 patches with [state-id = current-state-id][
    set num-seats abs(round random-normal num-seats-m num-seats-sd)
    set num-voters abs(round random-normal voters-m voters-sd)
      if num-voters < 1 [set num-voters 1]
    ifelse not partys?[
        set num-candidates abs(round random-normal candidates-m candidates-sd)
        if num-candidates < 1 [set num-candidates 1]
      ][
        set num-candidates abs(round random-normal candidates-m candidates-sd)
        if num-candidates < 1 [set num-candidates 1]
        set num-partys abs(round random-normal partys-m partys-sd)
        if num-partys < 1 [set num-partys 1]
      ]
    let state-patches patches with [state-id = current-state-id]

    ; For each state, identified by its color, spawn n turtles
    ask one-of state-patches[
        sprout-voters num-voters [
          set voter-state-id [state-id] of patch-here
          set color black
          set shape "person"
          set size 1.5  ; Adjust size for visibility
          voter-policy
          if partys? [set my-party random num-partys]
        ]
       ]
      ask one-of state-patches [
         sprout-candidates num-candidates[
          set candidate-state-id [state-id] of patch-here
          set color white
          set shape "star"
          set size 1.5  ; Adjust size for visibility
          candidate-policy
          set winner? false
          set won-primary false
          set party-id random num-partys
         ]
        ]
      ]
     ]
  ask one-of patches[
       if partys? [
          let next-party-id 1
          sprout-partys num-partys[
          ; set party-state-id [state-id] of patch-here
          set party-n-id next-party-id
        ; Increment next-party-id for the next party
          set next-party-id next-party-id + 1
          set shape "circle"
          setxy random-xcor random-ycor
          set size 2  ; Adjust size for visibility
          party-policy
         ]
        ]
  ]
end

to voter-policy
  ask voters[
          set policy-A-preference-values abs(round random-normal policy-A-m policy-A-sd)
            if policy-A-preference-values > 10 [set policy-A-preference-values 10]
            if policy-A-preference-values < 1 [set policy-A-preference-values 1]
          set policy-A-importance-values (abs(round random-normal policy-A-imp-m policy-A-imp-sd) / 10)
                if policy-A-importance-values > 1 [set policy-A-importance-values 1]
                if policy-A-importance-values < 0 [set policy-A-importance-values 0]
          set policy-B-preference-values abs(round random-normal policy-B-m policy-B-sd)
            if policy-B-preference-values > 10 [set policy-B-preference-values 10]
            if policy-B-preference-values < 1 [set policy-B-preference-values 1]
          set policy-B-importance-values (abs(round random-normal policy-B-imp-m policy-B-imp-sd) / 10)
                if policy-B-importance-values > 1 [set policy-B-importance-values 1]
                if policy-B-importance-values < 0 [set policy-B-importance-values 0]
          set policy-C-preference-values abs(round random-normal policy-C-m policy-C-sd)
            if policy-C-preference-values > 10 [set policy-C-preference-values 10]
            if policy-C-preference-values < 1 [set policy-C-preference-values 1]
          set policy-C-importance-values (abs(round random-normal policy-C-imp-m policy-C-imp-sd) / 10)
                if policy-C-importance-values > 1 [set policy-C-importance-values 1]
                if policy-C-importance-values < 0 [set policy-C-importance-values 0]
          set policy-D-preference-values abs(round random-normal policy-D-m policy-D-sd)
            if policy-D-preference-values > 10 [set policy-D-preference-values 10]
            if policy-D-preference-values < 1 [set policy-D-preference-values 1]
          set policy-D-importance-values (abs(round random-normal policy-D-imp-m policy-D-imp-sd) / 10)
                if policy-D-importance-values > 1 [set policy-D-importance-values 1]
                if policy-D-importance-values < 0 [set policy-D-importance-values 0]
          set policy-E-preference-values abs(round random-normal policy-E-m policy-E-sd)
            if policy-E-preference-values > 10 [set policy-E-preference-values 10]
            if policy-E-preference-values < 1 [set policy-E-preference-values 1]
          set policy-E-importance-values (abs(round random-normal policy-E-imp-m policy-E-imp-sd) / 10)
                if policy-E-importance-values > 1 [set policy-E-importance-values 1]
                if policy-E-importance-values < 0 [set policy-E-importance-values 0]
  ]
end

to candidate-policy
  ask candidates[
          set policy-A-positions abs(round random-normal policy-A-position-m policy-A-position-sd)
                if policy-A-positions > 10 [set policy-A-positions 10]
                if policy-A-positions < 1 [set policy-A-positions 1]
          set policy-B-positions abs(round random-normal policy-B-position-m policy-B-position-sd)
                if policy-B-positions > 10 [set policy-B-positions 10]
                if policy-B-positions < 1 [set policy-B-positions 1]
          set policy-C-positions abs(round random-normal policy-C-position-m policy-C-position-sd)
                if policy-C-positions > 10 [set policy-C-positions 10]
                if policy-C-positions < 1 [set policy-C-positions 1]
          set policy-D-positions abs(round random-normal policy-D-position-m policy-D-position-sd)
                if policy-D-positions > 10 [set policy-D-positions 10]
                if policy-D-positions < 1 [set policy-D-positions 1]
          set policy-E-positions abs(round random-normal policy-E-position-m policy-E-position-sd)
                if policy-E-positions > 10 [set policy-E-positions 10]
                if policy-E-positions < 1 [set policy-E-positions 1]
     set winner? false
  ]
end

to party-policy
  ask partys[
          set party-policy-A-positions abs(round random-normal party-policy-A-position-m party-policy-A-position-sd)
                if party-policy-A-positions > 10 [set party-policy-A-positions 10]
                if party-policy-A-positions < 1 [set party-policy-A-positions 1]
          set party-policy-B-positions abs(round random-normal party-policy-B-position-m party-policy-B-position-sd)
                if party-policy-B-positions > 10 [set party-policy-B-positions 10]
                if party-policy-B-positions < 1 [set party-policy-B-positions 1]
          set party-policy-C-positions abs(round random-normal party-policy-C-position-m party-policy-C-position-sd)
                if party-policy-C-positions > 10 [set party-policy-C-positions 10]
                if party-policy-C-positions < 1 [set party-policy-C-positions 1]
          set party-policy-D-positions abs(round random-normal party-policy-D-position-m party-policy-D-position-sd)
                if party-policy-D-positions > 10 [set party-policy-D-positions 10]
                if party-policy-D-positions < 1 [set party-policy-D-positions 1]
          set party-policy-E-positions abs(round random-normal party-policy-E-position-m party-policy-E-position-sd)
                if party-policy-E-positions > 10 [set party-policy-E-positions 10]
                if party-policy-E-positions < 1 [set party-policy-E-positions 1]
          set party-mean-position ((party-policy-A-positions + party-policy-B-positions + party-policy-C-positions + party-policy-D-positions + party-policy-E-positions) / 5)
  ]
end

; Designate patches with lower and higher averages for a variable
to assign-averages
  ask patches[
  ; Assuming 'n' is a predefined number for lower/higher states
  let total-states sort patches
  let conservative-states n-of conservative-districts patches
  let liberal-states n-of liberal-districts patches with [not member? self conservative-states]

  ; Assign lower and higher resource levels
  ask conservative-states [set pcolor red + 1  ; Example variable adjustment
                     ]
  ask liberal-states [set pcolor blue - 1]
  ]
end

to assign-party
  ask candidates[
    let my-state candidate-state-id
      create-links-to other partys [
      ; set hidden? true
    ]

   let p-utilities-list []
   ask my-links [
       let p-utility (candidate-party-utility-calc myself [end2] of self)  ; Adjust based on actual end of the link the candidate is on
       set p-utilities-list fput (list p-utility self) p-utilities-list
   ]
    let sorted-utilities sort-by [[a b] -> item 0 a > item 0 b] p-utilities-list

    if (length sorted-utilities > 0) [
      set party-a [end2] of item 1 (item 0 sorted-utilities)  ; Highest utility candidate
;    if (length sorted-utilities > 1) [
;      set party-b [end2] of item 1 (item 1 sorted-utilities)  ; Second highest utility candidate
;  ]
;    if (length sorted-utilities > 2) [
;      set party-c [end2] of item 1 (item 2 sorted-utilities)  ; Third highest utility candidate
;  ]
 ]
    ask links [die]
]

end


to-report candidate-party-utility-calc [candidate1 party1]
  ; Example utility calculation

      let cand-pref-a [policy-A-positions] of candidate1                                                                         ;; setup Resource variable and coordinates of each actor connected
      let party-pref-a [party-policy-A-positions] of party1
      let cand-pref-b [policy-B-positions] of candidate1                                                                         ;; setup Resource variable and coordinates of each actor connected
      let party-pref-b [party-policy-B-positions] of party1
      let cand-pref-c [policy-C-positions] of candidate1                                                                         ;; setup Resource variable and coordinates of each actor connected
      let party-pref-c [party-policy-C-positions] of party1
      let cand-pref-d [policy-D-positions] of candidate1                                                                         ;; setup Resource variable and coordinates of each actor connected
      let party-pref-d [party-policy-D-positions] of party1
      let cand-pref-E [policy-E-positions] of candidate1                                                                         ;; setup Resource variable and coordinates of each actor connected
      let party-pref-e [party-policy-E-positions] of party1

      let A-dif abs([cand-pref-a] of candidate1 - [party-pref-a] of party1)
      let B-dif abs([cand-pref-b] of candidate1 - [party-pref-b] of party1)
      let C-dif abs([cand-pref-c] of candidate1 - [party-pref-c] of party1)
      let D-dif abs([cand-pref-d] of candidate1 - [party-pref-d] of party1)
      let E-dif abs([cand-pref-e] of candidate1 - [party-pref-e] of party1)

      report (A-dif) + (B-dif) + (C-dif) + (D-dif) + (E-dif)
end



; MAIN SIMULATION LOOP
TO go
  if ticks < 1 [
  determine-vote
  simulate-elections
  ]
  update-visuals
  tick
END

to Determine-vote
  if Election-type = "Majoritarian" [rank-candidates-for-voters]
  if Election-type = "Majoritarian" and Primary? [rank-candidates-for-voters-primary]
  if Election-type = "Proportional" [rank-partys-for-voters]
end

to rank-candidates-for-voters
ask voters[
    let my-state voter-state-id
      create-links-to other candidates with [candidate-state-id = my-state] [
      ; set hidden? true
    ]

   let utilities-list []
   ask my-links [
       let utility (utility-calc myself [end2] of self)  ; Adjust based on actual end of the link the candidate is on
       set utilities-list fput (list utility self) utilities-list
   ]
    let sorted-utilities sort-by [[a b] -> item 0 a > item 0 b] utilities-list

    if (length sorted-utilities > 0) [
      set candidate-1 [end2] of item 1 (item 0 sorted-utilities)  ; Highest utility candidate
    if (length sorted-utilities > 1) [
      set candidate-2 [end2] of item 1 (item 1 sorted-utilities)  ; Second highest utility candidate
  ]
    if (length sorted-utilities > 2) [
      set candidate-3 [end2] of item 1 (item 2 sorted-utilities)  ; Third highest utility candidate
  ]
 ]
]
end

to rank-candidates-for-voters-primary
ask voters[
    let my-state voter-state-id
    let my-party-id my-party
      create-links-to other candidates with [candidate-state-id = my-state and party-id = my-party-id] [
      ; set hidden? true
    ]

   let utilities-list []
   ask my-links [
       let utility (utility-calc myself [end2] of self)  ; Adjust based on actual end of the link the candidate is on
       set utilities-list fput (list utility self) utilities-list
   ]
    let sorted-utilities sort-by [[a b] -> item 0 a > item 0 b] utilities-list

    if (length sorted-utilities > 0) [
      set candidate-1 [end2] of item 1 (item 0 sorted-utilities)  ; Highest utility candidate
    if (length sorted-utilities > 1) [
      set candidate-2 [end2] of item 1 (item 1 sorted-utilities)  ; Second highest utility candidate
  ]
    if (length sorted-utilities > 2) [
      set candidate-3 [end2] of item 1 (item 2 sorted-utilities)  ; Third highest utility candidate
  ]
 ]
]
end

to rank-candidates-for-voters-general
ask voters[
    let my-state voter-state-id
      create-links-to other candidates with [candidate-state-id = my-state and won-primary = True] [
      ; set hidden? true
    ]

   let utilities-list []
   ask my-links [
       let utility (utility-calc myself [end2] of self)  ; Adjust based on actual end of the link the candidate is on
       set utilities-list fput (list utility self) utilities-list
   ]
    let sorted-utilities sort-by [[a b] -> item 0 a > item 0 b] utilities-list

    if (length sorted-utilities > 0) [
      set candidate-1 [end2] of item 1 (item 0 sorted-utilities)  ; Highest utility candidate
    if (length sorted-utilities > 1) [
      set candidate-2 [end2] of item 1 (item 1 sorted-utilities)  ; Second highest utility candidate
  ]
    if (length sorted-utilities > 2) [
      set candidate-3 [end2] of item 1 (item 2 sorted-utilities)  ; Third highest utility candidate
  ]
 ]
]
end

to-report utility-calc [voter1 candidate1]
  ; Example utility calculation

      let voter-pref-a [policy-A-preference-values] of voter1                                                                         ;; setup Resource variable and coordinates of each actor connected
      let cand-pref-a [policy-A-positions] of candidate1
      let voter-pref-b [policy-B-preference-values] of voter1                                                                         ;; setup Resource variable and coordinates of each actor connected
      let cand-pref-b [policy-B-positions] of candidate1
      let voter-pref-c [policy-C-preference-values] of voter1                                                                         ;; setup Resource variable and coordinates of each actor connected
      let cand-pref-c [policy-C-positions] of candidate1
      let voter-pref-d [policy-D-preference-values] of voter1                                                                         ;; setup Resource variable and coordinates of each actor connected
      let cand-pref-d [policy-D-positions] of candidate1
      let voter-pref-E [policy-E-preference-values] of voter1                                                                         ;; setup Resource variable and coordinates of each actor connected
      let cand-pref-e [policy-E-positions] of candidate1

      let A-dif abs([voter-pref-a] of voter1 - [cand-pref-a] of candidate1)
      let B-dif abs([voter-pref-b] of voter1 - [cand-pref-b] of candidate1)
      let C-dif abs([voter-pref-c] of voter1 - [cand-pref-c] of candidate1)
      let D-dif abs([voter-pref-d] of voter1 - [cand-pref-d] of candidate1)
      let E-dif abs([voter-pref-e] of voter1 - [cand-pref-e] of candidate1)

      let voter-imp-a [policy-A-importance-values] of voter1
      let voter-imp-b [policy-B-importance-values] of voter1
      let voter-imp-c [policy-C-importance-values] of voter1
      let voter-imp-d [policy-D-importance-values] of voter1
      let voter-imp-e [policy-E-importance-values] of voter1

      report (voter-imp-a * A-dif) + (voter-imp-b * B-dif) + (voter-imp-c * C-dif) + (voter-imp-d * D-dif) + (voter-imp-e * E-dif)
end

to rank-partys-for-voters
ask voters[
    let my-state voter-state-id
      create-links-to other partys [
      set hidden? true
    ]

   let utilities-list []
   ask my-links [
       let utility (voter-party-utility-calc myself [end2] of self)  ; Adjust based on actual end of the link the candidate is on
       set utilities-list fput (list utility self) utilities-list
   ]
    let sorted-utilities sort-by [[a b] -> item 0 a > item 0 b] utilities-list

    if (length sorted-utilities > 0) [
      set party-1 [end2] of item 1 (item 0 sorted-utilities)  ; Highest utility candidate
    if (length sorted-utilities > 1) [
      set party-2 [end2] of item 1 (item 1 sorted-utilities)  ; Second highest utility candidate
  ]
    if (length sorted-utilities > 2) [
      set party-3 [end2] of item 1 (item 2 sorted-utilities)  ; Third highest utility candidate
  ]
 ]
]


end

to-report voter-party-utility-calc [voter1 party1]
  ; Example utility calculation

      let voter-pref-a [policy-A-preference-values] of voter1                                                                         ;; setup Resource variable and coordinates of each actor connected
      let party-pref-a [party-policy-A-positions] of party1
      let voter-pref-b [policy-B-preference-values] of voter1                                                                         ;; setup Resource variable and coordinates of each actor connected
      let party-pref-b [party-policy-B-positions] of party1
      let voter-pref-c [policy-C-preference-values] of voter1                                                                         ;; setup Resource variable and coordinates of each actor connected
      let party-pref-c [party-policy-C-positions] of party1
      let voter-pref-d [policy-D-preference-values] of voter1                                                                         ;; setup Resource variable and coordinates of each actor connected
      let party-pref-d [party-policy-D-positions] of party1
      let voter-pref-E [policy-E-preference-values] of voter1                                                                         ;; setup Resource variable and coordinates of each actor connected
      let party-pref-e [party-policy-E-positions] of party1

      let A-dif abs([voter-pref-a] of voter1 - [party-pref-a] of party1)
      let B-dif abs([voter-pref-b] of voter1 - [party-pref-b] of party1)
      let C-dif abs([voter-pref-c] of voter1 - [party-pref-c] of party1)
      let D-dif abs([voter-pref-d] of voter1 - [party-pref-d] of party1)
      let E-dif abs([voter-pref-e] of voter1 - [party-pref-e] of party1)

      let voter-imp-a [policy-A-importance-values] of voter1
      let voter-imp-b [policy-B-importance-values] of voter1
      let voter-imp-c [policy-C-importance-values] of voter1
      let voter-imp-d [policy-D-importance-values] of voter1
      let voter-imp-e [policy-E-importance-values] of voter1

      report (voter-imp-a * A-dif) + (voter-imp-b * B-dif) + (voter-imp-c * C-dif) + (voter-imp-d * D-dif) + (voter-imp-e * E-dif)
end

; SIMULATE VARIOUS ELECTORAL SYSTEMS
TO simulate-elections
  ; Example: Simulate a majoritarian election
  ask voters [
    if Election-Type = "Majoritarian" [vote-majoritarian]
    if Election-Type = "Majoritarian" and Primary? [primary-general-election]
    if Election-Type = "Proportional" [vote-proportional]
    if Election-Type = "Proportional" and Election-Threshold [primary-general-election]
  ]
  ; Add procedures for PR, RCV, MMP, etc., as per model requirements
END

; VOTER DECISION MAKING
TO vote-majoritarian  ; Simplified example for majoritarian voting
; Reset selection count at the start of each voting process
  ask candidates [
    set votes 0
  ]

  let state-ids remove-duplicates [state-id] of voters ; Assuming voters and candidates share the same set of state-ids
  foreach state-ids [
    current-state-id ->
    ; Increment selection count for candidate-1 chosen by voters in this state
    ask voters with [state-id = current-state-id] [
      ; Assuming logic to determine candidate-1 is already executed
      if not rank-choice [equal-vote]
      if rank-choice [rank-vote]
    ]

    ; Now identify the candidate with the highest selection count in this state
   ;; let winner max-one-of (candidates with [state-id = current-state-id]) [votes]

    ; Find the maximum number of votes among candidates in the current state
    let max-votes max [votes] of (candidates with [state-id = current-state-id])

    ; Filter candidates who have this maximum number of votes
    let top-candidates candidates with [state-id = current-state-id and votes = max-votes]

    ; Randomly select one of these candidates as the winner
    let winner one-of top-candidates

        ; Set the winner's winner? variable to true
    ask winner [
      set winner? true
    ]
  ]
END

to equal-vote
      ask candidate-1 [  ; This needs to be determined prior in your model
        set votes votes + 1
      ]
      if num-votes = 2[
        ask candidate-2 [
         set votes votes + 1
        ]
      ]
      if num-votes = 3[
         ask candidate-3 [
            set votes votes + 1
        ]
      ]
end

to rank-vote
      ask candidate-1 [  ; This needs to be determined prior in your model
        set votes votes + 3
      ]
      if num-votes = 2[
        ask candidate-2 [
         set votes votes + 2
        ]
      ]
      if num-votes = 3[
         ask candidate-3 [
            set votes votes + 1
        ]
      ]
end

to primary-general-election
  primary-vote
  rank-candidates-for-voters-general
  general-vote
end

to primary-vote
; Reset selection count at the start of each voting process
  ask candidates [
    set votes 0
  ]

  let state-ids remove-duplicates [state-id] of voters ; Assuming voters and candidates share the same set of state-ids
  let party-ids remove-duplicates [party-id] of candidates ; Assuming this is how you get party IDs
  foreach state-ids [
    current-state-id ->
    ; Increment selection count for candidate-1 chosen by voters in this state
    ask voters with [state-id = current-state-id] [
      ; Assuming logic to determine candidate-1 is already executed
      if not rank-choice [equal-vote]
      if rank-choice [rank-vote]
    ]

    ; Now identify the candidate with the highest selection count in this state
   ;; let winner max-one-of (candidates with [state-id = current-state-id]) [votes]

    ; Find the maximum number of votes among candidates in the current state
    foreach party-ids [
      current-party-id ->
      let candidate-votes [votes] of candidates with [state-id = current-state-id and party-id = current-party-id]
      if not empty? candidate-votes [
      let max-votes max [votes] of (candidates with [state-id = current-state-id and party-id = current-party-id])

    ; Filter candidates who have this maximum number of votes
      let top-candidates candidates with [state-id = current-state-id and party-id = current-party-id and votes = max-votes]

    ; Randomly select one of these candidates as the winner
      if any? top-candidates [
        let won-primary? one-of top-candidates
        ask won-primary? [ set won-primary true ]
      ]
     ]
   ]
  ]
end


to general-vote
; Reset selection count at the start of each voting process
  ask candidates [
    set votes 0
  ]

  let state-ids remove-duplicates [state-id] of voters ; Assuming voters and candidates share the same set of state-ids
  foreach state-ids [
    current-state-id ->
    ; Increment selection count for candidate-1 chosen by voters in this state
    ask voters with [state-id = current-state-id] [
      ; Assuming logic to determine candidate-1 is already executed
      if not rank-choice [equal-vote]
      if rank-choice [rank-vote]
    ]

    ; Now identify the candidate with the highest selection count in this state
   ;; let winner max-one-of (candidates with [state-id = current-state-id]) [votes]

    ; Find the maximum number of votes among candidates in the current state
    let max-votes max [votes] of (candidates with [state-id = current-state-id])

    ; Filter candidates who have this maximum number of votes
    let top-candidates candidates with [state-id = current-state-id and votes = max-votes]

    ; Randomly select one of these candidates as the winner
    let winner one-of top-candidates

        ; Set the winner's winner? variable to true
    ask winner [
      set winner? true
    ]
  ]

end

to vote-proportional
; Reset selection count at the start of each voting process
  ask partys [
    set district-seat-shares []
    set won-seats 0
    set total-votes 0
  ]

  let state-ids remove-duplicates [state-id] of voters ; Assuming voters and candidates share the same set of state-ids
  foreach state-ids [
    current-state-id ->


    ; Reset selection count at the start of each voting process
    ask partys [
      set p-votes 0
    ]

    ; Increment selection count for candidate-1 chosen by voters in this state
    ask voters with [state-id = current-state-id] [
      ; Assuming logic to determine candidate-1 is already executed
      if not rank-choice [p-equal-vote]
      if rank-choice [p-rank-vote]
    ]
;
;
;    ; Okay, need to calculate the percent of votes each party receives. Then translate this into the number of seats.
    let total-votes-in-state count voters with [voter-state-id = current-state-id]
    if num-votes = 2 and not rank-choice [set total-votes-in-state total-votes-in-state * 2]
    if num-votes = 3 and not rank-choice [set total-votes-in-state total-votes-in-state * 3]
    if num-votes = 2 and rank-choice [set total-votes-in-state total-votes-in-state * 3]
    if num-votes = 3 and rank-choice [set total-votes-in-state total-votes-in-state * 6]
    set total-votes total-votes-in-state + total-votes


    let district-num-seats [num-seats] of one-of patches with [state-id = current-state-id and num-seats > 0]
    set total-seats sum [num-seats] of patches with [num-seats > 0]
    ask partys [
      let party-votes-in-state p-votes
      if total-votes-in-state > 0 [
        let vote-share (party-votes-in-state / total-votes-in-state)
        let district-won-seats round(vote-share * district-num-seats)
        set won-seats won-seats + district-won-seats
        set district-seat-shares lput (list current-state-id district-won-seats) district-seat-shares
      ]
    ]
  ]
  aggregate-national-seats
end

to aggregate-national-seats
  ask partys[
   set global-party-impact-A party-policy-A-positions *  won-seats / total-seats
   set global-party-impact-B party-policy-B-positions *  won-seats / total-seats
   set global-party-impact-C party-policy-C-positions *  won-seats / total-seats
   set global-party-impact-D party-policy-D-positions *  won-seats / total-seats
   set global-party-impact-E party-policy-E-positions *  won-seats / total-seats
  ]
   set legislature-party-position-A sum [global-party-impact-A] of partys
   set legislature-party-position-B sum [global-party-impact-B] of partys
   set legislature-party-position-C sum [global-party-impact-C] of partys
   set legislature-party-position-D sum [global-party-impact-D] of partys
   set legislature-party-position-E sum [global-party-impact-E] of partys
end

to p-equal-vote
      ask party-1 [  ; This needs to be determined prior in your model
        set p-votes p-votes + 1
      ]
      if num-votes = 2[
        ask party-2 [
         set p-votes p-votes + 1
        ]
      ]
      if num-votes = 3[
         ask party-3 [
            set p-votes p-votes + 1
        ]
      ]
end

to p-rank-vote
      ask party-1 [  ; This needs to be determined prior in your model
        set p-votes p-votes + 3
      ]
      if num-votes = 2[
        ask party-2 [
         set p-votes p-votes + 2
        ]
      ]
      if num-votes = 3[
         ask party-3 [
            set p-votes p-votes + 1
        ]
      ]
end


; ADDITIONAL PROCEDURES for electoral process dynamics, election thresholds, etc.


to update-visuals
  legislature-visuals
  district-visuals

end

to legislature-visuals
  if not partys? [
  set Med-Policy-A median [policy-A-positions] of candidates with [winner? = true]
  set Med-Policy-B median [policy-B-positions] of candidates with [winner? = true]
  set Med-Policy-C median [policy-C-positions] of candidates with [winner? = true]
  set Med-Policy-D median [policy-D-positions] of candidates with [winner? = true]
  set Med-Policy-E median [policy-E-positions] of candidates with [winner? = true]
  set Mean-Policy-A median [policy-A-positions] of candidates with [winner? = true]
  set Mean-Policy-B median [policy-B-positions] of candidates with [winner? = true]
  set Mean-Policy-C median [policy-C-positions] of candidates with [winner? = true]
  set Mean-Policy-D median [policy-D-positions] of candidates with [winner? = true]
  set Mean-Policy-E median [policy-E-positions] of candidates with [winner? = true]
  ]

  if partys?[


  ]

end


to district-visuals
  ask voters[
    set policy-A-importance-values-01 policy-A-importance-values * 10
    set policy-B-importance-values-01 policy-B-importance-values * 10
    set policy-C-importance-values-01 policy-C-importance-values * 10
    set policy-D-importance-values-01 policy-D-importance-values * 10
    set policy-E-importance-values-01 policy-E-importance-values * 10
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
190
37
848
696
-1
-1
13.0
1
10
1
1
1
0
1
1
1
0
49
0
49
0
0
1
ticks
30.0

SLIDER
6
368
178
401
voters-m
voters-m
0
100
6.0
1
1
NIL
HORIZONTAL

SLIDER
6
401
178
434
voters-sd
voters-sd
0
100
0.0
1
1
NIL
HORIZONTAL

TEXTBOX
29
335
179
360
District Values
20
0.0
1

TEXTBOX
116
701
255
751
Voter Values\n
20
0.0
1

SLIDER
1
736
173
769
policy-A-m
policy-A-m
0
100
5.0
1
1
NIL
HORIZONTAL

SLIDER
1
769
173
802
policy-A-sd
policy-A-sd
0
100
2.5
1
1
NIL
HORIZONTAL

SLIDER
1
834
173
867
policy-B-sd
policy-B-sd
0
100
2.5
1
1
NIL
HORIZONTAL

SLIDER
1
802
173
835
policy-B-m
policy-B-m
0
100
5.0
1
1
NIL
HORIZONTAL

SLIDER
1
867
173
900
policy-C-m
policy-C-m
0
100
5.0
1
1
NIL
HORIZONTAL

SLIDER
1
899
173
932
policy-C-sd
policy-C-sd
0
100
2.5
1
1
NIL
HORIZONTAL

SLIDER
1
931
173
964
policy-D-m
policy-D-m
0
100
5.0
1
1
NIL
HORIZONTAL

SLIDER
1
964
173
997
policy-D-sd
policy-D-sd
0
100
2.5
1
1
NIL
HORIZONTAL

SLIDER
1
997
173
1030
policy-E-m
policy-E-m
0
100
5.0
1
1
NIL
HORIZONTAL

SLIDER
1
1030
173
1063
policy-E-sd
policy-E-sd
0
100
2.5
1
1
NIL
HORIZONTAL

SLIDER
173
736
346
769
policy-A-imp-m
policy-A-imp-m
0
10
5.0
1
1
NIL
HORIZONTAL

SLIDER
173
769
345
802
policy-A-imp-sd
policy-A-imp-sd
0
10
2.5
1
1
NIL
HORIZONTAL

SLIDER
173
802
345
835
policy-B-imp-m
policy-B-imp-m
0
10
5.0
1
1
NIL
HORIZONTAL

SLIDER
173
834
345
867
policy-B-imp-sd
policy-B-imp-sd
0
10
2.5
1
1
NIL
HORIZONTAL

SLIDER
6
433
178
466
candidates-m
candidates-m
0
50
4.0
1
1
NIL
HORIZONTAL

SLIDER
6
466
178
499
candidates-sd
candidates-sd
0
50
0.0
1
1
NIL
HORIZONTAL

SLIDER
6
498
178
531
partys-m
partys-m
0
50
2.0
1
1
NIL
HORIZONTAL

SLIDER
6
531
178
564
partys-sd
partys-sd
0
50
0.0
1
1
NIL
HORIZONTAL

SLIDER
173
867
345
900
policy-C-imp-m
policy-C-imp-m
0
10
5.0
1
1
NIL
HORIZONTAL

SLIDER
173
899
345
932
policy-C-imp-sd
policy-C-imp-sd
0
10
2.5
1
1
NIL
HORIZONTAL

SLIDER
173
932
345
965
policy-D-imp-m
policy-D-imp-m
0
10
5.0
1
1
NIL
HORIZONTAL

SLIDER
173
964
345
997
policy-D-imp-sd
policy-D-imp-sd
0
10
2.5
1
1
NIL
HORIZONTAL

SLIDER
173
997
345
1030
policy-E-imp-m
policy-E-imp-m
0
10
5.0
1
1
NIL
HORIZONTAL

SLIDER
173
1029
345
1062
policy-E-imp-sd
policy-E-imp-sd
0
10
2.5
1
1
NIL
HORIZONTAL

TEXTBOX
378
705
590
755
Candidate Values\t
20
0.0
1

SLIDER
369
736
541
769
policy-A-position-m
policy-A-position-m
0
100
5.0
1
1
NIL
HORIZONTAL

SLIDER
369
769
541
802
policy-A-position-sd
policy-A-position-sd
0
100
2.5
1
1
NIL
HORIZONTAL

SLIDER
369
802
541
835
policy-B-position-m
policy-B-position-m
0
100
5.0
1
1
NIL
HORIZONTAL

SLIDER
369
834
541
867
policy-B-position-sd
policy-B-position-sd
0
100
2.5
1
1
NIL
HORIZONTAL

SLIDER
369
867
541
900
policy-C-position-m
policy-C-position-m
0
100
5.0
1
1
NIL
HORIZONTAL

SLIDER
369
900
541
933
policy-C-position-sd
policy-C-position-sd
0
100
2.5
1
1
NIL
HORIZONTAL

SLIDER
369
933
541
966
policy-D-position-m
policy-D-position-m
0
100
5.0
1
1
NIL
HORIZONTAL

SLIDER
369
966
541
999
policy-D-position-sd
policy-D-position-sd
0
100
2.5
1
1
NIL
HORIZONTAL

SLIDER
369
999
541
1032
policy-E-position-m
policy-E-position-m
0
100
5.0
1
1
NIL
HORIZONTAL

SLIDER
369
1032
541
1065
policy-E-position-sd
policy-E-position-sd
0
100
2.5
1
1
NIL
HORIZONTAL

SLIDER
6
564
178
597
Conservative-Districts
Conservative-Districts
0
100
0.0
1
1
NIL
HORIZONTAL

SLIDER
6
597
178
630
Liberal-Districts
Liberal-Districts
0
100
0.0
1
1
NIL
HORIZONTAL

TEXTBOX
591
706
741
731
Party Values\t\t
20
0.0
1

SLIDER
552
736
741
769
party-policy-A-position-m
party-policy-A-position-m
0
100
5.0
1
1
NIL
HORIZONTAL

SLIDER
552
769
741
802
party-policy-A-position-sd
party-policy-A-position-sd
0
100
2.5
1
1
NIL
HORIZONTAL

SLIDER
552
801
741
834
party-policy-B-position-m
party-policy-B-position-m
0
100
5.0
1
1
NIL
HORIZONTAL

SLIDER
552
833
741
866
party-policy-B-position-sd
party-policy-B-position-sd
0
100
2.5
1
1
NIL
HORIZONTAL

SLIDER
552
865
741
898
party-policy-C-position-m
party-policy-C-position-m
0
100
5.0
1
1
NIL
HORIZONTAL

SLIDER
552
898
741
931
party-policy-C-position-sd
party-policy-C-position-sd
0
100
2.5
1
1
NIL
HORIZONTAL

SLIDER
552
931
741
964
party-policy-D-position-m
party-policy-D-position-m
0
100
5.0
1
1
NIL
HORIZONTAL

SLIDER
552
964
741
997
party-policy-D-position-sd
party-policy-D-position-sd
0
100
2.5
1
1
NIL
HORIZONTAL

SLIDER
552
997
741
1030
party-policy-E-position-m
party-policy-E-position-m
0
100
5.0
1
1
NIL
HORIZONTAL

SLIDER
552
1030
741
1063
party-policy-E-position-sd
party-policy-E-position-sd
0
100
2.5
1
1
NIL
HORIZONTAL

BUTTON
26
24
90
57
Setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
90
24
153
57
Go
Go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SWITCH
19
143
157
176
Partys?
Partys?
0
1
-1000

CHOOSER
19
65
157
110
Election-Type
Election-Type
"Majoritarian" "Proportional"
1

PLOT
864
10
1064
160
Legislature Policy A Histogram
Policy-A
Frequency
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 1 -16777216 true "" "histogram [policy-A-positions] of candidates with [winner? = true]"

PLOT
864
159
1064
309
Legislature Policy B Histogram
Policy-B
Frequency
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 1 -16777216 true "" "histogram [policy-B-positions] of candidates with [winner? = true]"

PLOT
864
309
1064
459
Legislature Policy C Histogram
Policy-C
Frequency
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 1 -16777216 true "" "histogram [policy-C-positions] of candidates with [winner? = true]"

PLOT
864
458
1064
608
Legislature Policy D Histogram
Policy-D
Frequency
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 1 -16777216 true "" "histogram [policy-D-positions] of candidates with [winner? = true]"

PLOT
864
608
1064
758
Legislature Policy E Histogram
Policy-D
Frequency
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 1 -16777216 true "" "histogram [policy-E-positions] of candidates with [winner? = true]"

CHOOSER
1072
10
1210
55
View-State
View-State
1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25
4

MONITOR
1072
55
1137
100
Voters
count voters with [voter-state-id = view-state]
1
1
11

MONITOR
1072
100
1137
145
Candidates
count candidates with [candidate-state-id = view-state]
1
1
11

MONITOR
1137
55
1194
100
Partys
count partys with [party-state-id = view-state]
1
1
11

PLOT
1551
10
1751
160
Voters Policy-A Importance Histogram
Policy-A Importance
Frequency
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 1 -16777216 true "" "histogram [policy-A-importance-values-01] of voters with [voter-state-id = view-state]"

PLOT
1352
10
1552
160
Voters Policy-A Position Histogram
Policy-A Position
Frequency
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 1 -16777216 true "" "histogram [policy-A-preference-values] of voters with [voter-state-id = view-state]"

PLOT
1352
160
1552
310
Voters Policy-B Position Histogram
Policy-B Position
Frequency
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 1 -16777216 true "" "histogram [policy-B-preference-values] of voters with [voter-state-id = view-state]"

PLOT
1353
310
1553
460
Voters Policy-C Position Histogram
Policy-C Postion
Frequency
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 1 -16777216 true "" "histogram [policy-C-preference-values] of voters with [voter-state-id = view-state]"

PLOT
1353
460
1553
610
Voters Policy-D Position Histogram
Policy-D Position
Frequency
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 1 -16777216 true "" "histogram [policy-D-preference-values] of voters with [voter-state-id = view-state]"

PLOT
1353
610
1553
760
Voters Policy-E Position Histogram
Policy-E Position
Frequency
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 1 -16777216 true "" "histogram [policy-E-preference-values] of voters with [voter-state-id = view-state]"

PLOT
1552
160
1752
310
Voters Policy-B Importance Histogram
Policy-B Importance
Frequency
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 1 -16777216 true "" "histogram [policy-B-importance-values-01] of voters with [voter-state-id = view-state]"

PLOT
1553
311
1753
461
Voters Policy-C Importance Histogram
Policy-C Importance
Frequency
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 1 -16777216 true "" "histogram [policy-C-importance-values-01] of voters with [voter-state-id = view-state]"

PLOT
1553
461
1753
611
Voters Policy-D Importance Histogram
Policy-D Importance
Frequency
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 1 -16777216 true "" "histogram [policy-D-importance-values-01] of voters with [voter-state-id = view-state]"

PLOT
1553
610
1753
760
Voters Policy-E Importance Histogram
Policy-E Importance
Frequency
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 1 -16777216 true "" "histogram [policy-E-importance-values-01] of voters with [voter-state-id = view-state]"

MONITOR
1212
10
1284
55
Max Policy A
max [Policy-A-preference-values] of voters with [voter-state-id = view-state]
17
1
11

MONITOR
1211
54
1284
99
Avg Policy A
mean [Policy-A-preference-values] of voters with [voter-state-id = view-state]
17
1
11

MONITOR
1284
10
1352
55
Min Policy A
min [Policy-A-preference-values] of voters with [voter-state-id = view-state]
17
1
11

MONITOR
1280
54
1352
99
Med Policy A
median [Policy-A-preference-values] of voters with [voter-state-id = view-state]
17
1
11

MONITOR
1211
160
1282
205
Max Policy-B
max [Policy-B-preference-values] of voters with [voter-state-id = view-state]
17
1
11

MONITOR
1282
160
1352
205
Min Policy-B
min [Policy-B-preference-values] of voters with [voter-state-id = view-state]
1
1
11

MONITOR
1211
205
1282
250
Avg Policy-B
mean [Policy-B-preference-values] of voters with [voter-state-id = view-state]
17
1
11

MONITOR
1280
205
1352
250
Med Policy-B
median [Policy-B-preference-values] of voters with [voter-state-id = view-state]
17
1
11

MONITOR
1285
310
1353
355
Min Policy-C
min [Policy-C-preference-values] of voters with [voter-state-id = view-state]
17
1
11

MONITOR
1213
310
1285
355
Max Policy-C
max [Policy-C-preference-values] of voters with [voter-state-id = view-state]
17
1
11

MONITOR
1213
354
1285
399
Avg Policy-C
mean [Policy-C-preference-values] of voters with [voter-state-id = view-state]
17
1
11

MONITOR
1282
354
1354
399
Med Policy-C
median [Policy-C-preference-values] of voters with [voter-state-id = view-state]
17
1
11

MONITOR
1213
460
1285
505
Max Policy-D
max [Policy-D-preference-values] of voters with [voter-state-id = view-state]
17
1
11

MONITOR
1213
504
1285
549
Avg Policy-D
mean [Policy-D-preference-values] of voters with [voter-state-id = view-state]
17
1
11

MONITOR
1285
460
1353
505
Min Policy-D
min [Policy-D-preference-values] of voters with [voter-state-id = view-state]
17
1
11

MONITOR
1282
504
1354
549
Med Policy-D
median [Policy-D-preference-values] of voters with [voter-state-id = view-state]
17
1
11

MONITOR
1215
610
1286
655
Max Policy-E
max [Policy-E-preference-values] of voters with [voter-state-id = view-state]
17
1
11

MONITOR
1286
610
1353
655
Min Policy-E
min [Policy-E-preference-values] of voters with [voter-state-id = view-state]
17
1
11

MONITOR
1215
655
1286
700
Avg Policy-E
mean [Policy-E-preference-values] of voters with [voter-state-id = view-state]
1
1
11

MONITOR
1283
655
1354
700
Med Policy-E
median [Policy-E-preference-values] of voters with [voter-state-id = view-state]
17
1
11

SLIDER
19
241
157
274
Num-Votes
Num-Votes
0
3
1.0
1
1
NIL
HORIZONTAL

TEXTBOX
1072
159
1222
184
Legislator Info
20
0.0
1

MONITOR
1072
191
1185
236
Legislator Policy-A
[policy-A-positions] of candidates with [candidate-state-id = view-state and winner?]
17
1
11

MONITOR
1072
236
1185
281
Legislator Policy-B
[policy-B-positions] of candidates with [candidate-state-id = view-state and winner? ]
17
1
11

MONITOR
1072
281
1185
326
Legislator Policy-C
[policy-C-positions] of candidates with [candidate-state-id = view-state and winner? ]
17
1
11

MONITOR
1072
326
1183
371
Legislator Policy-D
[policy-D-positions] of candidates with [candidate-state-id = view-state and winner? ]
17
1
11

MONITOR
1072
370
1185
415
Legislator Policy-E
[policy-E-positions] of candidates with [candidate-state-id = view-state and winner? ]
17
1
11

SWITCH
19
176
157
209
Primary?
Primary?
0
1
-1000

SWITCH
19
209
157
242
Rank-Choice
Rank-Choice
1
1
-1000

SLIDER
6
630
178
663
num-seats-m
num-seats-m
0
100
6.0
1
1
NIL
HORIZONTAL

SLIDER
6
663
178
696
num-seats-sd
num-seats-sd
0
100
2.0
1
1
NIL
HORIZONTAL

MONITOR
1151
985
1296
1030
NIL
legislature-party-position-A
2
1
11

MONITOR
861
938
951
983
NIL
total-votes
17
1
11

PLOT
861
984
1061
1134
Party-Seats-Won
Party-ID
Seats-Won
0.0
10.0
0.0
100.0
true
true
"" ""
PENS
"Party 1" 1.0 0 -3844592 true "" "plot sum [won-seats] of partys with [party-n-id = 1]"
"Party 2" 1.0 0 -14439633 true "" "plot sum [won-seats] of partys with [party-n-id = 2]"
"Party 3" 1.0 0 -14070903 true "" "plot sum [won-seats] of partys with [party-n-id = 3]"

MONITOR
1295
985
1438
1030
NIL
legislature-party-position-B
2
1
11

MONITOR
1438
985
1580
1030
NIL
legislature-party-position-C
2
1
11

MONITOR
1580
984
1744
1029
NIL
legislature-party-position-D
2
1
11

MONITOR
1743
984
1906
1029
NIL
legislature-party-position-E
2
1
11

MONITOR
1061
1030
1151
1075
Party-1-Seats
sum [won-seats] of partys with [party-n-id = 1]
17
1
11

MONITOR
1061
1074
1151
1119
Party-2-Seats
sum [won-seats] of partys with [party-n-id = 2]
1
1
11

MONITOR
1061
1118
1151
1163
Party-3-Seats
sum [won-seats] of partys with [party-n-id = 3]
17
1
11

MONITOR
1061
985
1151
1030
NIL
total-seats
17
1
11

MONITOR
1151
1029
1296
1074
party-policy-position-A
sum [party-policy-A-positions] of partys with [party-n-id = 1]
1
1
11

MONITOR
1296
1029
1438
1074
party-policy-position-B
sum [party-policy-B-positions] of partys with [party-n-id = 1]
17
1
11

MONITOR
1438
1029
1581
1074
party-policy-position-C
sum [party-policy-C-positions] of partys with [party-n-id = 1]
17
1
11

MONITOR
1580
1029
1744
1074
party-policy-position-D
sum [party-policy-D-positions] of partys with [party-n-id = 1]
17
1
11

MONITOR
1744
1029
1906
1074
party-policy-position-E
sum [party-policy-E-positions] of partys with [party-n-id = 1]
1
1
11

MONITOR
1150
1074
1297
1119
party-policy-position-A
sum [party-policy-A-positions] of partys with [party-n-id = 2]
17
1
11

MONITOR
1296
1074
1439
1119
party-policy-position-B
sum [party-policy-B-positions] of partys with [party-n-id = 2]
17
1
11

MONITOR
1438
1074
1581
1119
party-policy-position-C
sum [party-policy-C-positions] of partys with [party-n-id = 2]
17
1
11

MONITOR
1581
1074
1745
1119
party-policy-position-D
sum [party-policy-D-positions] of partys with [party-n-id = 2]
17
1
11

MONITOR
1744
1074
1906
1119
party-policy-position-E
sum [party-policy-E-positions] of partys with [party-n-id = 2]
17
1
11

MONITOR
1150
1118
1297
1163
party-policy-position-A
sum [party-policy-A-positions] of partys with [party-n-id = 3]
17
1
11

MONITOR
1296
1118
1439
1163
party-policy-position-B
sum [party-policy-B-positions] of partys with [party-n-id = 3]
17
1
11

MONITOR
1439
1118
1582
1163
party-policy-position-C
sum [party-policy-C-positions] of partys with [party-n-id = 3]
17
1
11

MONITOR
1581
1118
1745
1163
party-policy-position-D
sum [party-policy-D-positions] of partys with [party-n-id = 3]
17
1
11

MONITOR
1745
1118
1906
1163
party-policy-position-E
sum [party-policy-E-positions] of partys with [party-n-id = 3]
17
1
11

PLOT
860
788
1060
938
Primary Winners Policy A Histogram
Policy-A
Frequency
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 1 -16777216 true "" "histogram [policy-A-positions] of candidates with [won-primary = true]"

PLOT
1060
788
1260
938
Primary Winners Policy-B Histogram
Policy-B
Frequency
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 1 -16777216 true "" "histogram [policy-B-positions] of candidates with [won-primary = true]"

PLOT
1260
788
1460
938
Primary Winners Policy C Histogram
Policy-C
Frequency
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 1 -16777216 true "" "histogram [policy-C-positions] of candidates with [won-primary = true]"

PLOT
1460
788
1660
938
Primary Winners Policy D Histogram
Policy-D
Frequency
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 1 -16777216 true "" "histogram [policy-D-positions] of candidates with [won-primary = true]"

SWITCH
19
110
158
143
Election-Threshold
Election-Threshold
1
1
-1000

SLIDER
19
274
157
307
Election-Threshold
Election-Threshold
0
1
0.05
1
1
NIL
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.3.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
