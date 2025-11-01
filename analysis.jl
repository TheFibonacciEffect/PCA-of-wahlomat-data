using CSV
using DataFrames
using Statistics

df = CSV.read("Wahl-O-Mat Bundestagswahl 2025_Datensatz_v1.02.csv", DataFrame)
df[:,[1,7]]

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

data = select(df, ["Partei: Kurzbezeichnung", "Position"])


