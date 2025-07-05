;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; GROCERY STORE OPERATIONAL FLOW AGENT-BASED MODEL
;; Phases 1 to 5 covered
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

globals [
  restock-count
  waste-count
  opening-time
  closing-time
  entrance-x
  entrance-y
  successful-payments
]

turtles-own [
  on-shift?       ;; working status
  shift-start     ;; shift begins
  shift-end       ;; shift ends
  on-break?       ;; break status
  break-time      ;; scheduled break
  state           ;; customer: shopping / queuing / paying / exiting etc
  department      ;; for staff specialization or customer assistance
  cashier-sales  ;; total sales per cashier
]

patches-own [
  stocked-item
  inventory-level
  expiry-date
  discounted
  has-spill
]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; SETUP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to setup
  clear-all
  set restock-count 0
  set waste-count 0
  set opening-time 8 * 60        ;; 8am
  set closing-time 21 * 60       ;; 9pm
  reset-ticks                      ;; << move this here
  setup-environment
  setup-agents
  set successful-payments 0
end


to setup-environment
  ask patches [
    set stocked-item "none"
    set inventory-level 0
    set expiry-date 0
    set discounted false
    set has-spill false
  ]
  ;; single entrance/exit at left side middle
  set entrance-x min-pxcor
  set entrance-y 0

  ask patch entrance-x entrance-y [
    set pcolor green
  ]
  ;; queue area
  ask patches with [pxcor = max-pxcor - 1 and pycor mod 4 = 0] [
    set pcolor black
  ]

  ask patches with [pxcor >= -5 and pxcor <= 5 and pycor >= 7 and pycor <= 9] [
  set stocked-item "apples"
  set inventory-level 10
  set expiry-date ticks + 20
]
  ask patches with [pxcor >= -5 and pxcor <= 5 and pycor <= -7 and pycor >= -9] [
  set stocked-item "beef"
  set inventory-level 10
  set expiry-date ticks + 20
]
  ask patches with [pxcor >= -5 and pxcor <= 5 and pycor >= -5 and pycor <= 5] [
  set stocked-item "rice"
  set inventory-level 10
  set expiry-date ticks + 20
]
  ;; cashiers right side
  ask patches with [
  pxcor = max-pxcor or pxcor = max-pxcor - 1
  and pycor >= (max-pycor - (3 * 19))
  and pycor <= max-pycor
] [
  set pcolor gray
]


end



to setup-agents
  ;; customers
  create-turtles 200 [
  set state "entering"
  set department "customer"
  set on-shift? false
  set on-break? false
  set shift-start 0
  set shift-end 0
  set break-time 0
  set shape "person"
  set color blue
  ;; start exactly on the entrance
  setxy entrance-x entrance-y
  set cashier-sales 0
]

  ;; cashiers
  create-turtles 20 [
  set department "cashier"
  set on-shift? true
  set shape "person"
  set color green
  set shift-start opening-time
  set shift-end closing-time
  set on-break? false
  set break-time ticks + 60 + random 30

  ;; spacing 3 patches apart vertically
  let cashier-y (max-pycor - (3 * who))
  setxy (max-pxcor - 6) cashier-y
  ]

  ;; stockers
  create-turtles 10 [
    set department "stocker"
    set shape "person"
    setxy 0 0
    set on-shift? true
    set color orange
    set shift-start opening-time
    set shift-end closing-time
    set on-break? false
    set break-time ticks + 60 + random 30
  ]

  ;; packers
  create-turtles 20 [
  set department "packer"
  set on-shift? true
  set shape "person"
  set color cyan
  set shift-start opening-time
  set shift-end closing-time
  set on-break? false
  set break-time ticks + 60 + random 30

  ;; place exactly 1 patch left of their matching cashier
  let packer-y (max-pycor - (3 * who))
  setxy (max-pxcor - 5) packer-y
  ]

  ;; cleaners
  create-turtles 5 [
    set department "cleaner"
    setxy 0 0
    set on-shift? true
    set shape "person"
    set color pink
    set shift-start opening-time
    set shift-end closing-time
    set on-break? false
    set break-time ticks + 60 + random 30
  ]

  ;; produce staff
  create-turtles 2 [
    set department "produce"
    let x-pos -10 + (who * 3)    ;; -4 and 0
    setxy x-pos -8
    set on-shift? true
    set color magenta
    set shift-start opening-time
    set shift-end closing-time
    set on-break? false
    set break-time ticks + 60 + random 30
  ]

  ;; butcher
  create-turtles 2 [
    set department "butcher"
    let x-pos -10 + (who * 3)    ;; 4 and 8
    setxy x-pos -8
    set on-shift? true
    set color brown
    set shift-start opening-time
    set shift-end closing-time
    set on-break? false
    set break-time ticks + 60 + random 30
  ]

  ;; manager
  create-turtles 2 [
    set department "manager"
    setxy random-xcor random-ycor
    set on-shift? true
    set color yellow
    set shift-start opening-time
    set shift-end closing-time
    set on-break? false
    set break-time ticks + 60 + random 30
  ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; GO
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to go
  if ticks < opening-time [
    store-preparation
  ]

  ;; store open
  if ticks >= opening-time and ticks < closing-time [

    ;; 8am - 10am
    if ticks >= 8 * 60 and ticks < 10 * 60 [
      store-preparation
      ask turtles with [department = "stocker" and on-shift?] [ monitor-shelves ]
    ]

    ;; 12pm - 2pm
    if ticks >= 12 * 60 and ticks < 14 * 60 [
      customer-journey
      core-operational-processes
      ask turtles with [department = "cashier" and on-shift?] [ serve-customers ]
      ask turtles with [department = "cleaner" and on-shift?] [ monitor-spills ]
    ]

    ;; 4pm - 6pm
    if ticks >= 16 * 60 and ticks < 18 * 60 [
      customer-journey
      core-operational-processes
      ask turtles with [department = "packer" and on-shift?] [ pack-customers ]
      ask turtles with [department = "butcher" and on-shift?] [ monitor-shelves ]
    ]

    ;; 7pm - 9pm
    if ticks >= 19 * 60 and ticks < 21 * 60 [
      core-operational-processes
      ask turtles with [department = "produce" and on-shift?] [ check-expiry ]
      ask turtles with [department = "manager"] [ monitor-queues ]
    ]

    ;; all hours in between still allow customer journey
    customer-journey
    support-operations
  ]

  ;; closing after 9pm
  if ticks >= closing-time [
  ;; forcibly clear all customers
    ask turtles with [department = "customer"] [
      show (word "Customer " who " forced to leave at closing time " ticks)
      set state "exiting"
      move-to-exit
      die
    ]

    ;; force all staff off-shift
    ask turtles with [department != "customer"] [
      set on-shift? false
      die
    ]

    closing-operations

    show (word "Store closed at " ticks " minutes. Restocks: " restock-count ", Waste: " waste-count)
    show (word "Total customers who paid: " successful-payments)
    ask turtles with [department = "cashier"] [
      show (word "Cashier " who " handled total sales of " cashier-sales " pesos")
    ]

    stop
  ]
  update-pcolors
  plot-stats
  tick
  plot-queues
  plot-cashiers
  plot-payments
  plot-customers
  plot-staff-breaks
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; PLOTS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to plot-stats
  set-current-plot "Restocks vs Waste"
  set-current-plot-pen "restocks"
  plotxy ticks restock-count
  set-current-plot-pen "waste"
  plotxy ticks waste-count
end

to plot-queues
  set-current-plot "Queue Length Over Time"
  set-current-plot-pen "queue-length"
  let queue-size count turtles with [department = "customer" and state = "queuing"]
  plotxy ticks queue-size
end

to plot-cashiers
  set-current-plot "Cashier Utilization"
  set-current-plot-pen "active-cashiers"
  let active-cashiers count turtles with [department = "cashier" and on-shift?]
  plotxy ticks active-cashiers
end

to plot-payments
  set-current-plot "Payments Over Time"
  set-current-plot-pen "payments"
  plotxy ticks successful-payments
end

to plot-customers
  set-current-plot "Customers in Store Over Time"
  set-current-plot-pen "customers"
  let customer-count count turtles with [department = "customer"]
  plotxy ticks customer-count
end

to plot-staff-breaks
  set-current-plot "Staff on Break Over Time"
  set-current-plot-pen "staff-breaks"
  let breaks count turtles with [department != "customer" and on-break?]
  plotxy ticks breaks
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; PHASE 1 - Store Preparation
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to store-preparation
  ;; simulate trucks arriving, stocking shelves etc
  ask turtles with [department = "stocker"] [
    fd 0.5
  ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; PHASE 2 - Customer Journey
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to customer-journey
  ask turtles with [department = "customer"] [
    if state = "entering" [
      move-to-shelves
    ]
    if state = "browsing" [
      ifelse random 100 < 50 [
        set state "seek-department-assist"
      ][
        set state "queuing"
      ]
    ]

    if state = "seek-department-assist" [
      department-assist
    ]
    if state = "queuing" [
      move-to-queue
    ]
    if state = "paying" [
      pay-at-cashier
    ]
    if state = "exiting" [
      move-to-exit
    ]
  ]
end


to department-assist
  ;; randomly pick butcher or produce staff
  ifelse random 100 < 50 [
    let butcher one-of turtles with [department = "butcher" and on-shift?]
    if butcher != nobody [
      face butcher
      fd 0.5
      if distance butcher < 1 [
        ;; simulate quick help
        ask butcher [ set color violet ]
        ;; continue to queue after
        set state "queuing"
      ]
    ]
  ][
    let produce one-of turtles with [department = "produce" and on-shift?]
    if produce != nobody [
      face produce
      fd 0.5
      if distance produce < 1 [
        ;; simulate quick help
        ask produce [ set color violet ]
        ;; continue to queue after
        set state "queuing"
      ]
    ]
  ]
end
to select-products
  let target one-of patches with [inventory-level > 0]
  if target != nobody [
    face target
    fd 0.5
    if distance target < 1 [
      ask target [
        set inventory-level inventory-level - 1
      ]
      set state "queuing"
    ]
  ]
end

to join-checkout
  let cashier one-of turtles with [department = "cashier" and on-shift?]
  if cashier != nobody [
    face cashier
    fd 0.5
    if distance cashier < 1 [
      set state "paying"
    ]
  ]
end

to complete-payment
  if random 10 < 2 [
    set state "exiting"
  ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; PHASE 3 - Core Operational Processes
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to core-operational-processes
  ask turtles with [department = "cashier" and on-shift? and not on-break?] [
  serve-customers
  ]
  ask turtles with [department = "stocker" and on-shift?] [
    monitor-shelves
  ]
  ask turtles with [department = "packer" and on-shift?] [
    pack-customers
  ]
  ask turtles with [department = "packer" and on-shift? and not on-break?] [
    pack-customers
  ]
  ask turtles with [department = "manager"] [
    monitor-queues
  ]
end
to serve-customers
  let nearby-customer one-of turtles with [
    department = "customer" and
    state = "paying" and
    distance myself < 1
  ]
  if nearby-customer != nobody [
    ask nearby-customer [
      set state "exiting"
    ]
  ]
end

to monitor-shelves
  let low-stock patch-set patches with [inventory-level <= 2]
  if any? low-stock [
    let p one-of low-stock
    face p
    fd 0.5
    if distance p < 1 [
      ask p [
        set inventory-level 10
        set expiry-date ticks + 20
        set discounted false
      ]
      set restock-count restock-count + 1
    ]
  ]
end

to pack-customers
  let served-customer one-of turtles with [
    department = "customer" and
    state = "paying" and
    distance myself < 2
  ]
  if served-customer != nobody [
    ;; simulate helping by changing their color
    set color violet
  ]
end


to monitor-queues
  ;; manager goes to check if any cashier queue is too long
  let overcrowded-cashiers turtles with [
    department = "cashier" and
    on-shift? and
    not on-break? and
    (count turtles with [
      department = "customer" and
      state = "queuing" and
      distance myself < 2
    ] > 5)
  ]

  if any? overcrowded-cashiers [
    ;; pick one overcrowded cashier to monitor
    let target-cashier one-of overcrowded-cashiers

    ;; move the manager near the cashier
    face target-cashier
    fd 0.5

    ;; show on the command center
    show (word "Manager monitoring queue at cashier " [who] of target-cashier)
  ]
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; PHASE 4 - Support Operations
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to support-operations
  ask turtles with [department = "cleaner" and on-shift?] [
    monitor-spills
  ]
  ask turtles with [department = "produce" and on-shift?] [
    check-expiry
  ]
  shift-management
end

to monitor-spills
  let target one-of patches with [has-spill]
  if target != nobody [
    face target
    fd 0.5
    ;; if close enough, clean the spill
    if distance target < 1 [
      ask target [ set has-spill false ]
      ;; cleaner shows cleaning action by changing color temporarily
      set color violet
    ]
  ]
  ;; return to default color after cleaning
  if color = violet and not any? patches with [has-spill] [
    set color pink
  ]
end


to check-expiry
  let p one-of patches with [inventory-level > 0 and expiry-date - ticks <= 5]
  if p != nobody [
    ask p [ set discounted true ]
  ]
  ask patches with [expiry-date <= ticks and inventory-level > 0] [
    set waste-count waste-count + inventory-level
    set inventory-level 0
    set discounted false
    set expiry-date ticks + 20
  ]
end

to shift-management
  ask turtles with [
    department != "customer"
  ] [
    ;; check if it is time for a break
    if not on-break? and ticks >= break-time [

      let total count turtles with [
        department = [department] of myself and on-shift?
      ]

      let currently-onbreak count turtles with [
        department = [department] of myself and on-break?
      ]

      let cover count turtles with [
        department = [department] of myself and
        on-shift? and
        not on-break? and
        self != myself
      ]

      if department = "cashier" [
        ;; allow break if there is at least one other cashier and no other cashier on break
        if cover >= 1 and currently-onbreak = 0 [
          set on-break? true
          set break-time ticks + 5 + 60 + random 30
        ]
      ]

      if department != "cashier" [
        ;; allow break if there is at least one other coworker, and no more than 20% on break
        if cover >= 1 and (currently-onbreak / total) < 0.2 [
          set on-break? true
          set break-time ticks + 5 + 60 + random 30
        ]
      ]
    ]

    ;; end the break
    if on-break? and ticks >= break-time [
      set on-break? false
    ]

    ;; end of shift
    if ticks >= shift-end [
      set on-shift? false
      die
    ]
  ]
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; PHASE 5 - Closing Operations
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to closing-operations
  ask turtles with [department = "cashier"] [
    close-register
  ]
  ask turtles with [department = "stocker"] [
    night-restock
  ]
  final-clean  ;; observer calls directly, no turtle
end


to close-register
  show (word "Cashier " who " closing register.")
end

to night-restock
  ask patches with [inventory-level < 5] [
    set inventory-level 10
    set expiry-date ticks + 20
    set discounted false
  ]
end

to final-clean
  ask patches [
    set has-spill false
  ]
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; VISUALS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to update-pcolors
  ask patches [
    ifelse has-spill [
      set pcolor brown
    ]
    [ ifelse discounted [
        set pcolor red
      ]
      [ ifelse stocked-item = "apples" [
          set pcolor green
        ]
        [ ifelse stocked-item = "beef" [
            set pcolor orange
          ]
          [ ifelse stocked-item = "rice" [
              set pcolor yellow
            ]
            [ set pcolor white ]
          ]
        ]
      ]
    ]
  ]
end

to move-to-shelves
  let target patch random-xcor random-ycor
  ifelse [stocked-item] of target != "" [
    face target
    fd 1
    if distance target < 1 [
      set state "browsing"
    ]
  ][
    ;; if random patch is not stocked, just wander
    rt random 360
    fd 1
  ]
end

to browse-items
  ;; wander in shelves for random time
  rt random 20 - 10
  fd 0.5
  ;; after shopping, queue
  if random 100 < 2 [
    set state "queuing"
  ]
end

to move-to-queue
  ;; find nearest cashier on shift and not on break
  let my-cashier min-one-of turtles with [
    department = "cashier" and on-shift? and not on-break?
  ] [distance myself]

  if my-cashier = nobody [
    ;; no cashier found, wander
    rt random 30 - 15
    fd 0.2
  ]

  if my-cashier != nobody [
    let queue-length count turtles with [
      department = "customer" and
      state = "queuing" and
      distance my-cashier < 2
    ]

    if queue-length > 5 [
      ;; look for alternative cashier
      let alt-cashier min-one-of turtles with [
        department = "cashier" and on-shift? and not on-break? and self != my-cashier
      ] [
        count turtles with [
          department = "customer" and
          state = "queuing" and
          distance self < 2
        ]
      ]

      if alt-cashier != nobody [
        let alt-queue count turtles with [
          department = "customer" and
          state = "queuing" and
          distance alt-cashier < 2
        ]

        ifelse alt-queue <= 5 [
          face alt-cashier
          fd 1
          show (word "Customer " who " switched to shorter queue at cashier " [who] of alt-cashier)
          set state "queuing"
        ]
        [
          ;; no better alternative found, wander a bit
          rt random 30 - 15
          fd 0.2
        ]
      ]
      if alt-cashier = nobody [
        ;; no other cashier at all
        if random 100 < 20 [
          set state "exiting"
          show (word "Customer " who " left due to long queues at all cashiers at time " ticks)
        ]
      ]
    ]
    if queue-length <= 5 [
      ;; acceptable, continue to queue
      join-checkout
    ]
  ]
end

to pay-at-cashier
  ;; stand still to simulate paying
  if random 100 < 5 [
    ;; find the closest cashier
    let my-cashier min-one-of turtles with [
      department = "cashier" and on-shift?
    ] [distance myself]

    ifelse my-cashier != nobody [
    ask my-cashier [
      set cashier-sales cashier-sales + 100 ;; e.g. 100 pesos per customer
    ]
      show (word "Customer " who " completed payment at cashier " [who] of my-cashier " at time " ticks)
    ][
      show (word "Customer " who " completed payment (no cashier found) at time " ticks)
    ]

    set successful-payments successful-payments + 1
    set state "exiting"
  ]
end

to move-to-exit
  let exit-patch patch entrance-x entrance-y
  face exit-patch
  fd 1
  if distance exit-patch < 1 [
    die
    show (word "Customer exited. Remaining customers: " count turtles with [department = "customer"])
  ]
end

@#$#@#$#@
GRAPHICS-WINDOW
715
30
1100
416
-1
-1
11.42424242424243
1
10
1
1
1
0
1
1
1
-16
16
-16
16
0
0
1
ticks
30.0

BUTTON
45
11
108
44
setup
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
110
10
173
43
go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
11
134
108
179
Restock Count
restock-count
17
1
11

MONITOR
110
45
198
90
Waste Count
waste-count
17
1
11

MONITOR
31
45
108
90
Active Spills
count patches with [ has-spill ]
17
1
11

MONITOR
109
134
203
179
On Break Staff
count turtles with [on-break?]
17
1
11

MONITOR
109
90
197
135
Off Shift Staff
count turtles with [not on-shift?]
17
1
11

MONITOR
108
180
208
225
Cashiers Closed
count turtles with [department = \"cashier\" and not on-shift?]
17
1
11

PLOT
297
26
500
186
Cashier Utilization
Time (minutes)
Number of Active Cashiers
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"active-cashiers" 1.0 0 -10899396 true "" ""

MONITOR
107
268
242
313
number of customers
count turtles with [department = \"customer\"]
17
1
11

MONITOR
26
89
108
134
current time
(word floor (ticks / 60) \":\" precision (ticks mod 60) 0)
17
1
11

PLOT
300
186
500
336
Restocks vs Waste
Time (minutes)
Count
0.0
1440.0
0.0
100.0
true
true
"" ""
PENS
"restocks" 1.0 0 -13345367 true "" ""
"waste" 1.0 0 -2674135 true "" ""

MONITOR
108
223
229
268
inventory warnings
count patches with [inventory-level <= 2]
17
1
11

PLOT
499
26
699
186
Customers in Store Over Time
Time (minutes)
Number of Customers
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"customers" 1.0 0 -5825686 true "" ""

PLOT
499
185
699
335
Queue Length Over Time
Time (minutes)
Number of Customers in Queue
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"queue-length" 1.0 0 -13345367 true "" ""

PLOT
300
334
500
484
Payments Over Time
Time (minutes) 
Number of Successful Payments
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"payments" 1.0 0 -13345367 true "" ""

PLOT
499
335
699
485
Total Inventory Level
Time (minutes)
Total Units in Store
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"inventory" 1.0 0 -6459832 true "" "plot count turtles"

PLOT
99
335
299
485
Staff on Break Over Time
Time (minutes)
Staff on Break
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"staff-breaks" 1.0 0 -2674135 true "" ""

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
NetLogo 6.4.0
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
