module Main exposing (main)

import Html exposing (..)
import Html.Attributes exposing (..)

main : Html String
main = view initialModel

view : Model -> Html String
view model =
    div [ id "main" ]
        [ h2 [] [ text "Champions"]
        , div [] <| championsImgs model
        ]

championsImgs : Model -> List (Html String)
championsImgs champions =
    List.map championImg champions

championImg : Champion -> Html String
championImg champion =
    img [ src <| "https://cdn.leagueofgraphs.com/img/tft/champions/" ++ champion.imageUrl ] []

initialModel : Model
initialModel =
    [ { imageUrl = "236.png", name = "Lucian", health = 550 }
    , { imageUrl = "143.png", name = "Zyra", health = 500 }
    ]

type alias Model = List Champion
type alias Champion = { imageUrl : String, name : String, health : Int }
