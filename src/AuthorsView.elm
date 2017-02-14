module AuthorsView exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Utils exposing (dropDuplicates, onKeyDown)
import Countries
import MainMessages exposing (..)
import MainModel exposing (..)
import MainUpdate exposing (..)
import Encoders exposing (..)


view : Model -> Html Msg
view model =
    let
        authors =
            Encoders.authors (model.authors)

        affiliationLimit =
            model.affiliationLimit
    in
        div []
            [ renderAuthors model.authors model.class model.authorFields affiliationLimit
            , input [ class "hidden", id "authorsArray", name "authorsArray", value authors ] [ text authors ]
            , div [] (renderDataLists (getBlurredAuthorAffiliations model))
            ]


renderAuthors : List Author -> String -> List AuthorField -> Int -> Html Msg
renderAuthors authors authorsClass authorField affiliationLimit =
    let
        authorIndexTuples =
            authors
                |> List.length
                |> List.range 1
                |> List.map2 (,) authors
    in
        div [ class authorsClass ]
            [ div [ class "" ] (List.map (renderAuthor affiliationLimit authorField) authorIndexTuples)
            , div [ class "button button--tertiary", onClick AddAuthor ] [ text "Add Author" ]
            ]


authorDataClass : String
authorDataClass =
    "ma2"


renderAuthor : Int -> List AuthorField -> ( Author, Int ) -> Html Msg
renderAuthor affiliationLimit authorFields ( author, index ) =
    let
        addAffiliationButton =
            if affiliationLimit > (List.length author.affiliations) then
                div [ class "add-affiliation-to-author button button--tertiary" ]
                    [ div [ onClick (AddAffiliation author.id) ]
                        [ text "Add Affiliation to Author" ]
                    ]
            else
                div []
                    []
    in
        div [ class "author form__question-sub-section" ]
            [ div [ class "form__label" ] [ text ("Author " ++ toString index) ]
            , div [ class "form__question-sub-section--inline" ]
                --for each of the authorFields we want to add a div like this
                [ div [ class "form__question-sub-section--inline" ] (List.map (renderFieldResponses authorFields) author.fields)
                ]
            , span [ class "remove button button--secondary" ]
                [ div
                    [ onClick (DeleteAuthor author.id) ]
                    [ text "Remove Author" ]
                ]
            , div [ class "affiliates-dropdowns" ]
                [ (renderAffiliations author.affiliations author.id) ]
            , addAffiliationButton
            ]


renderFieldResponses authorFields authorFieldResponse =
    let
        authorField =
            authorFields
                |> List.filter (\a -> a.id == authorFieldResponse.authorFieldId)
                |> List.head
                |> Maybe.withDefault defaultAuthorFeild
    in
        div [ class "inline-element" ]
            [ label [ class "form__label" ] [ text authorField.name ]
            , input
                [ class "form__input last-name"
                  --  , onInput (UpdateLastName author.id)
                , value authorFieldResponse.value
                ]
                []
            ]


renderAffiliations : List Affiliation -> Int -> Html Msg
renderAffiliations affiliations authorId =
    let
        affiliationsLength =
            List.length affiliations

        indexList =
            List.range 1 affiliationsLength

        affilIndexTuples =
            List.map2 (,) affiliations indexList
    in
        div []
            [ affiliationsHeader
            , div [] (List.map (renderAffiliation authorId) affilIndexTuples)
            ]


affiliationsHeader : Html Msg
affiliationsHeader =
    div [ class "clearfix" ]
        []


renderAffiliation : Int -> ( Affiliation, Int ) -> Html Msg
renderAffiliation authorId ( affiliation, index ) =
    div [ class "affiliation form__question-sub-section" ]
        [ div [ class "form__label" ] [ text ("Affiliation " ++ toString index) ]
        , div
            [ class "remove button button--secondary"
            , onClick (DeleteAffiliation authorId affiliation.id)
            ]
            [ text "Remove Affiliation" ]
        , div
            [ class "form__question-sub-section--inline" ]
            [ div [ class "inline-element" ]
                [ label
                    [ class "form__label"
                    , for ("affiliationInstitution-" ++ toString index)
                    ]
                    [ text "Institution" ]
                , input
                    [ class "form__input institution"
                    , list "institutions-list"
                    , name "institution"
                    , onInput (UpdateInstitution authorId affiliation.id)
                    , onFocus (SetFocusedIds authorId affiliation.id)
                    , onKeyDown (SetAffiliationKeyDown affiliation.id)
                    , value affiliation.institution
                    ]
                    []
                ]
            , div [ class "inline-element" ]
                [ label
                    [ class "form__label"
                    , for ("affiliationCity-" ++ toString index)
                    ]
                    [ text "City" ]
                , input
                    [ class "city form__input"
                    , list "cities-list"
                    , name "city"
                    , onInput (UpdateCity authorId affiliation.id)
                    , onFocus (SetFocusedIds authorId affiliation.id)
                    , value affiliation.city
                    ]
                    []
                ]
            , div [ class "inline-element" ]
                [ label [ class "form__label" ] [ text "Country" ]
                , select
                    [ class "country form__input form__input--dropdown"
                    , list "countries-list"
                    , name "country"
                    , onInput (UpdateCountry authorId affiliation.id)
                    , onFocus (SetFocusedIds authorId affiliation.id)
                    , value affiliation.country
                    ]
                    (Countries.options affiliation.country)
                ]
            ]
        ]


renderDataLists affiliations =
    let
        renderOptions list =
            list |> dropDuplicates |> List.map renderOption
    in
        [ datalist [ id "institutions-list" ]
            (affiliations
                |> List.map .institution
                |> renderOptions
            )
        , datalist [ id "countries-list" ]
            (affiliations
                |> List.map .country
                |> renderOptions
            )
        , datalist [ id "cities-list" ]
            (affiliations
                |> List.map .city
                |> renderOptions
            )
        ]


renderOption x =
    option [ value x ] []
