
# Working Principle

The app aims to contribute OSM data via surveys and shall be used on-site. It is designed to be simple and usable without much prior knowledge.
The app does **not** try to be a full featured editor for complex mapping scenarios like JOSM, ID or Vespucci by any means.

## Core principles:
- The app only ever adds tags or elements and never deletes anything.
- Changes must be uploaded via a personal OSM user account and users authorize/login via OAuth2.
- Users never enter any tags directly, instead the app phrases questions and transforms the answers into OSM tags (similar to [StreetComplete](https://github.com/streetcomplete/StreetComplete)).

## Target Elements:
The app focuses on public transport related OSM elements. Therefore we first gather all nearby stops via the [Overpass API](https://wiki.openstreetmap.org/wiki/Overpass_API). Based on these stops we generate "stop areas", which are basically just circles enclosing one or more nearby stops with a minimal predefined radius. These make up the areas where we are looking for OSM elements via the [OSM API](https://wiki.openstreetmap.org/wiki/API_v0.6#Bounding_box_computation). Our main focus lies on elements with the key `public_transport=platform`. Some further relevant elements are: footways, steps, parking areas or toilets around the stop.

## Matching:
Our heuristics for displaying questions currently only work on a per element basis.
The currently available matching criteria are:
- key-value equality
- key exists
- key is missing
- element type equality (here we added "closed way" as an additional element type to the 3 main OSM elements: node, way and relation)

## Questions & Answers:
Questions try to be as clear and narrowed down as possible. Every answer of the user will usually be transformed into one single tag, but may also be transformed into multiple tags.
The app tries to present as less free text fields a possible. On the one hand to prevent wrong value inputs and typos, on the other hand to make answering questions quicker and more comfortable.
