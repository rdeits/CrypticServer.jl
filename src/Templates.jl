module Templates

using CrypticCrosswords: DerivedSolution
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
    """
    <form action="solve" method="GET">
        <label for="clue">Clue</label>
        <input id="clue" type="text" name="clue" value="$(sanitize(clue))"/>
        <label for="length">Length (optional)</label>
        <input id="length" type="number" name="length" value="$(string(length))"/>
        <label for="pattern">Pattern (regex, optional)</label>
        <input id="pattern" type="text" name="pattern" value="$(sanitize(pattern))"/>
        <input type="submit" value="Solve"/>
    </form>
    """
end

function HomeLink()
    """
    <h1><a href="/">CrypticCrosswords.jl</a></h1>
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
      </head>
      <body>
      $(body)
      </body>
    </html>
    """
end

end
