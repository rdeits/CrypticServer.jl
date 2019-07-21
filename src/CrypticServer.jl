module CrypticServer

using Mux: Mux, @app, page, serve
using CrypticCrosswords: CrypticCrosswords, solve, derive!, DerivedArc, DerivedSolution, explain
using HTTP: queryparams
using Sockets: @ip_str
using JSON: json, JSON

export main

lower(s::AbstractString) = s

function explain_to_string(derivation::DerivedSolution)
    io = IOBuffer()
    explain(io, derivation)
    String(take!(io))
end

function lower(arc::DerivedArc)
    Dict("output" => arc.output,
         "head" => CrypticCrosswords.lhs(CrypticCrosswords.rule(arc.arc)),
         "constituents" => [lower(c) for c in arc.constituents],
         "score" => arc.arc.score)
end

function lower(arc::DerivedSolution)
    Dict("answer" => arc.output,
         "similarity" => arc.similarity,
         "derivation" => lower(arc.derivation),
         "explanation" => explain_to_string(arc))
end

function split_query(app, req)
    req[:query_params] = queryparams(req[:query])
    app(req)
end

function maybe(f, value)
    if value !== nothing
        f(value)
    else
        value
    end
end

function solve_clue(req)
    @show req
    params = JSON.parse(req[:query_params]["params"])
    @show params
    solutions, state = solve(params["clue"],
                             length=params["length"],
                             pattern=Regex(params["pattern"]))
    derivations = Iterators.flatten([derive!(state, s) for s in Iterators.take(solutions, 10)])
    json([lower(d) for d in derivations])
end

const STATIC_DIR = normpath(joinpath(@__DIR__, "..", "frontend", "dist"))

function main(; host=ip"127.0.0.1", port=8000)
    @app server = (
        Mux.stack(Mux.todict, Mux.basiccatch, Mux.splitquery, Mux.toresponse),
        page("/solve",
             split_query,
             req -> Base.invokelatest(solve_clue, req)),
        page("/", req -> Mux.fresp(joinpath(STATIC_DIR, "index.html"))),
        Mux.files(STATIC_DIR, false),
        Mux.notfound())
    serve(server, host, port)
end



end
