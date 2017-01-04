local algorithmExamples = {}

local rawExamples = {
  {
    name = "Pythagoras Tree",
    code = [[start_string "0"

rule "1" -> "11"
rule "0" -> "1[0]0"

function "1" forward(2)
function "0" forward(2)
function "[" {save() rotate(-45)}
function "]" {load() rotate(45)}]]
  },
  {
    name = "Koch Curve",
    code = [[start_string "F"

rule "F" -> "F+F-F-F+F"

function "F" forward(2)
function "+" rotate(-90)
function "-" rotate(90)]]
  },
  {
    name = "Sierpinski Triangle",
    code = [[start_string "F-G-G"

rule "F" -> "F-G+F+G-F"
rule "G" -> "GG"

function "F" forward(7)
function "G" forward(7)
function "+" rotate(-120)
function "-" rotate(120)]]
  },
  {
    name = "Sierpinski Arrowhead Curve",
    code = [[start_string "A"

rule "A" -> "+B-A-B+"
rule "B" -> "-A+B+A-"

function "A" forward(4)
function "B" forward(4)
function "+" rotate(-60)
function "-" rotate(60)]]
  },
  {
    name = "Dragon Curve",
    code = [[start_string "FX"

rule "X" -> "X+YF+"
rule "Y" -> "-FX-Y"

function "F" forward(2)
function "-" rotate(-90)
function "+" rotate(90)]]
  },
  {
    name = "Fractal Plant",
    code = [[start_string "X"

rule "X" -> "F-[\[X]+X]+F[+FX]-X"
rule "F" -> "FF"

function "F" forward(4)
function "-" rotate(-25)
function "+" rotate(25)
function "[" save()
function "]" load()]]
  }
}

for i=0, #rawExamples - 1 do
  if i%helpListLength == 0 then
    algorithmExamples[i/helpListLength + 1] = {}
  end

  table.insert(algorithmExamples[math.floor(i/helpListLength) + 1], rawExamples[i + 1])
end

return algorithmExamples
