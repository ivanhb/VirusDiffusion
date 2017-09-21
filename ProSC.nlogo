turtles-own
[
  infected?           ;; if true, the turtle is infected
  resistant?          ;; if true, the turtle can't be infected
  virus-check-timer   ;; number of ticks since this turtle's last bt virus-check
  check-mail-timer    ;; number of ticks since this turtle's last mms virus check
  num-of-att          ;; number of attacks made 
  contacts            ;; list of contacts in the address book
]

to setup
  clear-all
  setup-nodes
  ;;Initial infected nodes
  ask n-of initial-infected-nodes turtles[ become-infected]
  reset-ticks
end


to setup-nodes
  set-default-shape turtles "dot"
  crt nodes-number
  [
    ;;Random position for the agents
    setxy (random-xcor * 0.95) (random-ycor * 0.95)
    set size 3
    ;;Set address book for the nodes
    set contacts []
    set contacts n-of mail-list-size turtles
    ;;All nodes initialy are Susceptible
    become-susceptible
    set virus-check-timer random bt-check-frequency
    set check-mail-timer 0
  ]
end


to go
  ask turtles [ 
    ;;Agents mobility
    if virus-diffusion = "mms" [fd 0 ]
    if virus-diffusion = "bluetooth" [fd 0.1]
    
    ;;Check frequency for BT
    set virus-check-timer virus-check-timer + 1
    if virus-check-timer >= bt-check-frequency [ set virus-check-timer 0 ]
    
    ;;Check frequency for MMS
    set check-mail-timer check-mail-timer + 1
    if check-mail-timer >= 720 [ set check-mail-timer 0 ]
   ]
  if virus-diffusion = "mms" [ spread-virus-via-mms]
  if virus-diffusion = "bluetooth" [ spread-virus-via-bluetooth]

  ;;Check recovery
  do-virus-checks
 
  ;;Stop execution
  if all? turtles [infected?] or all? turtles [not infected?]
    [ stop ]
  
  tick
end

;; turtle procedure to turn into Infected status
to become-infected  
  set infected? true
  set resistant? false
  set color red
end

;; turtle procedure to turn into Susceptible status
to become-susceptible
  set infected? false
  set resistant? false
  set color green
end

;; turtle procedure to turn into Resistant status
to become-resistant 
  set infected? false
  set resistant? true
  set color gray
end


to spread-virus-via-bluetooth
  ask turtles with [infected?]
    [ 
      let candidates turtles in-radius 1 with[not resistant?]
       if any? candidates [     
         ask candidates [ 
            if not infected?[
              ;;if the nodes belong to the market-share and they aren't aware nodes, they become infected
              if random-float 100 < market-share and random-float 100 > user-awareness
              [ become-infected]
            ] 
         ]    
       ]
    ]
end


to spread-virus-via-mms
  ask turtles with [infected?]
  [ 
      if mms-type = "Scanning"
      [
        let candidates turtles with[not resistant? and not infected?]
        if any? candidates [
          ;;Attack one random node
          ask one-of candidates [ 
            ;;Checking if the maximum number of attacks has been exceeded
            if random-float 100 < mms-spread-chance and num-of-att < max-attacks 
            [ become-infected
              set num-of-att num-of-att + 1 
            ]
          ]
        ]
      ]
      
      if mms-type = "Topological"
      [
         if any? contacts [
           ;;Send virus to my contacts
           ask contacts [ 
              if not infected? and not resistant? and random-float 100 < mms-spread-chance and num-of-att < max-attacks 
              [ become-infected
                set num-of-att num-of-att + 1 
              ]            
           ]
         ]
      ]    
  ]
end
  

to do-virus-checks
  if virus-diffusion = "bluetooth" [
    ask turtles with [infected? and virus-check-timer = 0]
    [
      if random 100 < recovery-chance[become-susceptible]
    ]
  ]
  if virus-diffusion = "mms" [
    ask turtles with [infected? and  check-mail-timer = 0]
    [
      if random-float 100 < user-awareness[
        if any? contacts [
            ask contacts [if not infected?[become-resistant] ]
        ]    
      ]
    ]
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
556
11
957
433
25
25
7.6735
1
10
1
1
1
0
1
1
1
-25
25
-25
25
1
1
1
ticks
30.0

SLIDER
287
321
492
354
recovery-chance
recovery-chance
0.0
10.0
0.5
0.1
1
%
HORIZONTAL

SLIDER
288
248
493
281
market-share
market-share
0.0
100
5
0.1
1
%
HORIZONTAL

BUTTON
659
446
754
486
NIL
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
769
446
864
486
NIL
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

PLOT
27
389
490
689
World Status
ticks
% of nodes
0.0
52.0
0.0
100.0
true
true
"" ""
PENS
"susceptible" 1.0 0 -10899396 true "" "plot (count turtles with [not infected? and not resistant?]) / (count turtles) * 100"
"infected" 1.0 0 -2674135 true "" "plot (count turtles with [infected?]) / (count turtles) * 100"
"resistant" 1.0 0 -7500403 true "" "plot (count turtles with [resistant?]) / (count turtles) * 100"

SLIDER
25
15
230
48
nodes-number
nodes-number
10
500
150
5
1
NIL
HORIZONTAL

SLIDER
288
284
493
317
bt-check-frequency
bt-check-frequency
1
20
20
1
1
ticks
HORIZONTAL

SLIDER
253
15
458
48
initial-infected-nodes
initial-infected-nodes
1
nodes-number
1
1
1
NIL
HORIZONTAL

SLIDER
27
336
242
369
mms-spread-chance
mms-spread-chance
0
1
0.2
0.01
1
%
HORIZONTAL

INPUTBOX
122
270
240
330
max-attacks
15
1
0
Number

CHOOSER
54
215
182
260
mms-type
mms-type
"Topological" "Scanning"
1

CHOOSER
178
94
316
139
virus-diffusion
virus-diffusion
"mms" "bluetooth"
0

TEXTBOX
37
183
229
205
MMS Virus Diffusion
18
0.0
1

TEXTBOX
287
185
537
229
Bluetooth Virus Diffusion
18
0.0
1

SLIDER
144
56
354
89
user-awareness
user-awareness
0
100
90
1
1
%
HORIZONTAL

INPUTBOX
28
270
114
330
mail-list-size
3
1
0
Number

@#$#@#$#@
## WHAT IS IT?
The NetLogo agents will represent the mobile phones which can appear in green, red or grey color, making them in  susceptible, infected or resistant status respectively. The total number of nodes and the initial number of infected phones can be initially chosen through two sliders.
After the initial data are initialized a method of virus diffusion must be chosen (MMS or BT) throw a chooser input, as a result of this decision all the relative parameters to the selected mechanism. Each kind of method request different type of parameters. The last general parameter value to set with a slider is the UA percentage (it will gain different meanings for the diffusion method selected).  
For Bluetooth we have the possibility to decide the Market-Share and the recovery chance, the recovery process can be carried in a specific time frequency.
On the other hand for MMS we need to decide first which type of diffusion we would like to use (Topological or Scanning) with a chooser, and the virus expansion probability, the virus diffusion will be made after each tick, which can represent the 2min needed for a typical MMS virus to copy itself on a new handset \cite{base} .In addition we will set the maximum number of attacks the virus can accomplish and the address book size for all the phones throw two input boxes.
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

bluetuth
true
0
Circle -7500403 true true 105 150 90
Line -7500403 true 150 135 150 75
Line -7500403 true 150 75 165 90
Line -7500403 true 165 90 150 105
Line -7500403 true 150 105 165 120
Line -7500403 true 165 120 150 135
Line -7500403 true 150 105 135 120
Line -7500403 true 150 105 135 90

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
1
Circle -7500403 true false 0 0 300
Circle -16777216 true false 0 0 300
Circle -2674135 false true -3 -3 306

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
Circle -7500403 true true 105 105 90

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

halo_shape
true
1
Circle -2674135 false true 90 90 120

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

mobile
true
14
Rectangle -16777216 true true 90 30 210 255
Rectangle -1 true false 105 45 195 210
Circle -1 true false 135 225 30
Rectangle -1 false false 90 30 210 255

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

turtle_halo
true
1
Circle -2674135 false true -15 -15 330

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

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.0.5
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
