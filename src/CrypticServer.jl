module CrypticServer

using Mux: Mux, @app, page, serve
using CrypticCrosswords: CrypticCrosswords, solve, derive!, DerivedArc, DerivedSolution, explain
using HTTP: queryparams
using Sockets: @ip_str
using JSON: json, JSON

export main

include("Templates.jl")
using .Templates

function split_query(app, req)
    req[:query_params] = queryparams(req[:query])
    app(req)
end

const STATIC_DIR = normpath(joinpath(@__DIR__, "..", "frontend", "dist"))

function maybe(f, dict, key, default=nothing)
    if key in keys(dict)
        f(dict[key])
    else
        default
    end
end

decode_clue(s::AbstractString) = replace(s, '+' => ' ')

function handle_solve(request, timeout=15.0)
    @show request
    params = request[:query_params]
    @show params
    clue = decode_clue(params["clue"])
    length = tryparse(Int, get(params, "length", ""))
    pattern = get(params, "pattern", "")
    @show clue length pattern
    start_time = time()
    timed_out = Ref(false)
    should_continue = let timed_out=timed_out, start_time=start_time, timeout=timeout
        function ()
            elapsed = time() - start_time
            if elapsed > timeout
                timed_out[] = true
                return false
            else
                return true
            end
        end
    end
    solutions, state = solve(clue,
                             length=length,
                             pattern=Regex(pattern),
                             should_continue=should_continue
                             )
    derivations = Iterators.flatten([derive!(state, s) for s in Iterators.take(solutions, 10)])
    Templates.Index(
        Templates.HomeLink() *
        Templates.ClueInput(clue, length, pattern) *
        (timed_out[] ? "<h3>Timed out</h3>" : Templates.Results(derivations))
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
