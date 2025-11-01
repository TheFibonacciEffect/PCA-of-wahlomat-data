# https://en.wikipedia.org/wiki/Principal_component_analysis#Singular_value_decomposition
using CSV
using DataFrames
using Statistics
using LinearAlgebra
using Plots

df = CSV.read("Wahl-O-Mat Bundestagswahl 2025_Datensatz_v1.02.csv", DataFrame)

function position_map(position)
    if position == "stimme zu"
        return 1
    elseif position == "stimme nicht zu"
        return -1
    else
        return 0
    end
end

transform!(df, "Position: Position" => ByRow(position_map) => :Position)
names(df)

data = select(df, ["Partei: Kurzbezeichnung", "Position", "These: Titel", "These: These"])

questions = groupby(data, "These: Titel")

titles = []
thesen = []
X = []
for q in questions
    push!(titles, q[1, "These: Titel"])
    push!(thesen, q[1, "These: These"])
    x = q[:,:Position]
    push!(X, x .- mean(x))
end
X = hcat(X...) |> Matrix{Float64}

vals, vects = eigen(X' * X)

scatter(vals)
w1 = vects[:, end]
w2 = vects[:, end-1]

plot(size=2 .* (800,600))
for (i,party) in enumerate(groupby(data, "Partei: Kurzbezeichnung"))
    party_positions = party[:,:Position]
    x = dot(party_positions, w1)
    y = dot(party_positions, w2)
    scatter!([x], [y], label=:none, marker = (5, 0.5, :cross), annotations = (x, y, text(party[1, "Partei: Kurzbezeichnung"], :left)))
end
plot!(xlabel="Erste Hauptkomponente", ylabel="Zweite Hauptkomponente", title="Parteien im Positionsraum")
display(current())

sortperm(w1, rev=true)[1:5] |> x -> w1[x]
sortperm(w1, rev=true)[1:5] |> x -> titles[x]
sortperm(w2, rev=true)[1:5] |> x -> titles[x]

function print_top_components(w, thesen)
    println("Top 5 Komponenten:")
    idxs = sortperm(w, rev=true)[1:5]
    for i in idxs
        println(round(w[i], digits=4), "  -  ", thesen[i])
    end
end

print_top_components(w1, thesen)
print_top_components(w2, thesen)
