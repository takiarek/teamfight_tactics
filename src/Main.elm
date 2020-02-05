module Main exposing (main)

import Html exposing (..)
import Html.Attributes exposing (..)

main : Html String
main = view initialModel

view : Model -> Html String
view model =
    div [ id "main" ]
        [ h2 [] [ text "Champions"]
        , div [] <| championsImgs model.champions
        , h3 [] [ text "Details" ]
        , div [] [ championImg model.selectedChampion, championDetailsView model.selectedChampion ]
        ]

championsImgs : List Champion -> List (Html String)
championsImgs champions =
    List.map championImg champions

championImg : Champion -> Html String
championImg champion =
    img [ src <| "https://cdn.leagueofgraphs.com/img/tft/champions/" ++ champion.imageUrl ] []

championDetailsView : Champion -> Html String
championDetailsView champion =
    div []
        [ p [] [ text champion.name ]
        , p [] [ text "Health: ", text <| String.fromInt champion.health ]
        ]

initialModel : Model
initialModel =
    { champions = [ lucian
                  , zyra
                  ]
    , selectedChampion = lucian
    }

type alias Model = { champions : List Champion, selectedChampion : Champion }
type alias Champion = { imageUrl : String, name : String, health : Int }

lucian : Champion
lucian = { imageUrl = "236.png", name = "Lucian", health = 550 }
zyra : Champion
zyra = { imageUrl = "143.png", name = "Zyra", health = 500 }
