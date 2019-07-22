module Templates

using CrypticCrosswords: DerivedSolution, explain
using HTTP: HTTP

sanitize(s::AbstractString) = replace(s, r"[<>]" => "")
sanitize(s) = sanitize(string(s)::AbstractString)

function explain_to_string(derivation::DerivedSolution)
    io = IOBuffer()
    explain(io, derivation)
    String(take!(io))
end

function Answer(s::DerivedSolution)
    """<h3>
    $(sanitize(s.output)) $(round(Int, s.similarity * 100))%
    </h3> """
end

function Explanation(s::DerivedSolution)
    sanitize(explain_to_string(s))
end

function Solution(s::DerivedSolution)
    """<div>
    $(Answer(s))
    $(Explanation(s))
    </div>"""
end

function Results(derived_solutions)
    """<div>
    <h2>Results</h2>
    $(join(Solution(s) for s in derived_solutions))
    </div>
    """
end

function ClueInput(clue="", length="", pattern="")
    if length === nothing
        length = ""
    end
    """
    <form action="solve" method="GET">
        <div class="flex-outer">
            <div class="flex-col" style="max-width: 90%">
                <label for="clue">Clue</label>
                <input id="clue" type="text" name="clue" value="$(sanitize(clue))" style="width: 40em; max-width: 100%"/>
            </div>
            <div class="spacer"></div>
            <div class="flex-col">
                <label for="length">Length (optional)</label>
                <input id="length" type="number" name="length" value="$(string(length))" style="width: 9em"/>
            </div>
            <div class="spacer"></div>
            <div class="flex-col">
                <label for="pattern">Regex (optional)</label>
                <input id="pattern" type="text" name="pattern" value="$(sanitize(pattern))" style="width: 10em"/>
            </div>
            <div class="spacer"></div>
            <input type="submit" value="Solve" style="margin-top: 1em"/>
        </div>
    </form>
    """
end

function HomeLink()
    """
    <div class="home-link">
        <h1><a href="/">CrypticCrosswords.jl</a></h1>
    </div>
    """
end

function Intro()
    """
    <p>
    This is a general tool for solving cryptic (or "British-style") crossword clues, written entirely in the <a href="https://julialang.org/">Julia</a> programming language. You can find the source code for the solver on Github at <a href="https://github.com/rdeits/CrypticCrosswords.jl">rdeits/CrypticCrosswords.jl</a>.
    </p>
    """
end

function Example(clue, length, pattern, answer)
    """
    <li>
        <form action="solve" method="GET">
            <input type="submit" id="try" value="Try"/>
            <input type="text" name="clue" value="$(sanitize(clue))" hidden />
            <input type="number" name="length" value="$(sanitize(length))" hidden />
            <input type="text" name="pattern" value="$(sanitize(pattern))" hidden />
            <label for="try">$(clue) ($(length)) $pattern &rarr; $(uppercase(answer))</label>
        </form>
    </li>
    """
end

function Examples()
    EXAMPLES = [
        ("Couch is unfinished until now", 4, "", "sofa"),
        ("Spin broken shingle", 7, "", "english"),
        ("Initially babies are naked", 4, "", "bare"),
        ("At first, congoers like us eschew solving hints", 5, "", "clues"),
        ("Initial meetings disappoint rosemary internally", 6, "", "intros"),
        ("M's Rob Titon pitching slider?", 10, "", "trombonist"),
        ("Aerial worker Anne on the way up", 7, "", "antenna"),
        ("In glee over unusual color", 10, "^o", "olive green")
    ]
    """
    <div>
    <h2>Examples</h2>
        <ul>
            $(join(Example(c...) for c in EXAMPLES))
        </ul>
    </div>
    """
end

function Style()
    """
    <style>
    h1,h2,h3 {
        font-family: 'lucida grande', sans-serif;
    }
    .flex-outer {
        display: flex;
        flex-wrap: wrap;
    }
    .flex-col {
        display: flex;
        flex-direction: column;
    }
    .flex-col label {
        padding-top: 1em;
        padding-bottom: 0.5em;
    }
    .spacer {
        width: 1em;
    }
    .home-link a {
        color: black;
    }
    </style>
    """
end


function Index(body)
    """
    <!DOCTYPE html>
    <html lang="en">
      <head>
        <meta charset="utf-8" />
        <link rel="shortcut icon" href="favicon.ico" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <meta name="theme-color" content="#000000" />
        <title>CrypticCrosswords.jl</title>
        $(Style())
      </head>
      <body style="background-color: whitesmoke;">
        <div style="background-color: white; width: 90%; margin: auto; max-width: 800pt; box-shadow: 2px 2px 8px #aaa; padding: 1em 1em 1em 1em">
                $(body)
        </div>
      </body>
    </html>
    """
end

end
