module Main exposing (main)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Http
import Json.Decode exposing (Decoder, int, list, string, succeed)
import Json.Decode.Pipeline exposing (optional, required)

type Msg
    = ClickedChampionImage Champion
    | GotChampions (Result Http.Error (List Champion))

main : Program () Model Msg
main = Browser.element
    { init = \_ -> (initialModel, initialCommand)
    , view = view
    , update = update
    , subscriptions = \_ -> Sub.none
    }

initialModel : Model
initialModel = { champions = Loading }

type alias Model = { champions : Champions }
type Champions
    = Loading
    | Errored String
    | Loaded (List Champion) Champion
type alias Champion = { imageUrl : String, name : String, health : Int }

initialCommand : Cmd Msg
initialCommand =
    Http.get
        { url = "https://5496ad64.ngrok.io/api/champions"
        , expect = Http.expectJson GotChampions <| list championDecoder
        }

championDecoder : Decoder Champion
championDecoder =
    succeed Champion
    |> required "imageUrl" string
    |> required "name" string
    |> required "health" int

view : Model -> Html Msg
view model =
    div [ id "main" ]
        [ h2 [] [ text "Champions"]
        , div []
          <| case model.champions of
                Loaded champions selectedChampion ->
                    [ div [] <| championsImgs champions
                    , h3 [] [ text "Details" ]
                    , div [] [ championImg selectedChampion, championDetailsView selectedChampion ]
                    ]
                Loading -> []
                Errored errorMessage ->
                    [ p [] [ text errorMessage ] ]
        ]

championsImgs : List Champion -> List (Html Msg)
championsImgs champions =
    List.map championImg champions

championImg : Champion -> Html Msg
championImg champion =
    img [ src <| "https://cdn.leagueofgraphs.com/img/tft/champions/" ++ champion.imageUrl
        , onClick <| ClickedChampionImage champion
        ]
        []

championDetailsView : Champion -> Html Msg
championDetailsView champion =
    div []
        [ p [] [ text champion.name ]
        , p [] [ text "Health: ", text <| String.fromInt champion.health ]
        ]

update : Msg -> Model -> (Model, Cmd Msg)
update message model =
    case message of
        ClickedChampionImage champion ->
            ({ model | champions = selectChampion champion model.champions }, Cmd.none)
        GotChampions (Ok champions) ->
            case champions of
                (firstChampion :: _) ->
                    ({ model | champions = Loaded champions firstChampion }, Cmd.none)
                [] ->
                    ({ model | champions = Errored "Empty list!" }, Cmd.none)
        GotChampions (Err _) ->
            ({ model | champions = Errored "Server error!" }, Cmd.none)

selectChampion : Champion -> Champions -> Champions
selectChampion champion champions =
    case champions of
        Loaded champs _ ->
            Loaded champs champion
        Loading ->
            champions
        Errored _ ->
            champions
