module CrypticServer

using Mux: Mux, @app, page, serve
using CrypticCrosswords: CrypticCrosswords, solve, derive!, DerivedArc, DerivedSolution, explain
using HTTP: queryparams
using Sockets: @ip_str
using JSON: json, JSON

export main

include("Templates.jl")
using .Templates

# lower(s::AbstractString) = s

# function explain_to_string(derivation::DerivedSolution)
#     io = IOBuffer()
#     explain(io, derivation)
#     String(take!(io))
# end

# function lower(arc::DerivedArc)
#     Dict("output" => arc.output,
#          "head" => CrypticCrosswords.lhs(CrypticCrosswords.rule(arc.arc)),
#          "constituents" => [lower(c) for c in arc.constituents],
#          "score" => arc.arc.score)
# end

# function lower(arc::DerivedSolution)
#     Dict("answer" => arc.output,
#          "similarity" => arc.similarity,
#          "derivation" => lower(arc.derivation),
#          "explanation" => explain_to_string(arc))
# end

function split_query(app, req)
    req[:query_params] = queryparams(req[:query])
    app(req)
end

# function maybe(f, value)
#     if value !== nothing
#         f(value)
#     else
#         value
#     end
# end

# function solve_clue(req)
#     @show req
#     params = JSON.parse(req[:query_params]["q"])
#     @show params
#     solutions, state = solve(params["clue"],
#                              length=params["length"],
#                              pattern=Regex(params["pattern"]))
#     derivations = Iterators.flatten([derive!(state, s) for s in Iterators.take(solutions, 10)])
#     json([lower(d) for d in derivations])
# end

const STATIC_DIR = normpath(joinpath(@__DIR__, "..", "frontend", "dist"))

function maybe(f, dict, key, default=nothing)
    if key in keys(dict)
        f(dict[key])
    else
        default
    end
end

decode_clue(s::AbstractString) = replace(s, '+' => ' ')

function handle_solve(request)
    @show request
    params = request[:query_params]
    @show params
    clue = decode_clue(params["clue"])
    length = tryparse(Int, get(params, "length", ""))
    pattern = get(params, "pattern", "")
    @show clue length pattern
    solutions, state = solve(clue, length=length, pattern=Regex(pattern))
    derivations = Iterators.flatten([derive!(state, s) for s in Iterators.take(solutions, 10)])
    Templates.Index(
        Templates.HomeLink() *
        Templates.ClueInput(clue, length, pattern) *
        Templates.Results(derivations)
    )
end

function handle_home(request)
    Templates.Index(
        Templates.HomeLink() *
        Templates.Intro() *
        Templates.ClueInput() *
        Templates.Examples()
    )
end

function main(; host=ip"127.0.0.1", port=8000)
    @app server = (
        Mux.stack(Mux.todict, Mux.basiccatch, Mux.splitquery, Mux.toresponse),
        page("/solve",
             split_query,
             req -> Base.invokelatest(handle_solve, req)),
        page("/",
             req -> Base.invokelatest(handle_home, req)),
        Mux.notfound())
    serve(server, host, port)
end



end
