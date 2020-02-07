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
    | ChosenChampionLevel Level

main : Program () Model Msg
main = Browser.element
    { init = \_ -> (initialModel, initialCommand)
    , view = view
    , update = update
    , subscriptions = \_ -> Sub.none
    }

initialModel : Model
initialModel = { champions = Loading, selectedChampionLevel = One }

type alias Model = { champions : Champions, selectedChampionLevel : Level }
type Champions
    = Loading
    | Errored String
    | Loaded (List Champion) Champion
type alias Champion = { imageUrl : String, name : String, levelOne : ChampionLevel, levelTwo : ChampionLevel, levelThree : ChampionLevel }
type alias ChampionLevel = { health : Int }

initialCommand : Cmd Msg
initialCommand =
    Http.get
        { url = "https://5496ad64.ngrok.io/api/champions"
        , expect = Http.expectJson GotChampions <| list championDecoder
        }

championDecoder : Decoder Champion
championDecoder =
    succeed Champion
    |> required "image_url" string
    |> required "name" string
    |> required "level_one" championLevelDecoder
    |> required "level_two" championLevelDecoder
    |> required "level_three" championLevelDecoder

championLevelDecoder : Decoder ChampionLevel
championLevelDecoder =
    succeed ChampionLevel
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
                    , div []
                          [ levelChooserView model.selectedChampionLevel
                          , championImg selectedChampion
                          , championDetailsView model.selectedChampionLevel selectedChampion
                          ]
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

levelChooserView : Level -> Html Msg
levelChooserView selectedLevel =
    div [] <| List.map (levelRadioButton selectedLevel) [One, Two, Three]


levelRadioButton : Level -> Level -> Html Msg
levelRadioButton selectedLevel level =
    label []
          [ input [ type_ "radio"
                  , name "champion-level"
                  , onClick <| ChosenChampionLevel level
                  , checked <| level == selectedLevel
                  ] []
          , text <| levelToString level
          ]

levelToString : Level -> String
levelToString level =
    case level of
        One -> "one"
        Two -> "two"
        Three -> "three"

type Level
    = One
    | Two
    | Three

championDetailsView : Level -> Champion -> Html Msg
championDetailsView level champion =
    div []
        [ p [] [ text champion.name ]
        , p [] [ text "Health: ", text <| championLevelView level champion ]
        ]

championLevelView : Level -> Champion -> String
championLevelView level champion =
    String.fromInt
    <| case level of
        One -> champion.levelOne.health
        Two -> champion.levelTwo.health
        Three -> champion.levelThree.health

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
        ChosenChampionLevel level ->
            ({ model | selectedChampionLevel = level }, Cmd.none)

selectChampion : Champion -> Champions -> Champions
selectChampion champion champions =
    case champions of
        Loaded champs _ ->
            Loaded champs champion
        Loading ->
            champions
        Errored _ ->
            champions
