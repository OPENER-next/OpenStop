# OPENER next

The successor of the famous OPENER App.


## Before Compiling

**Rename** `config.example.json` to `config.json` in the `assets/cfg` directory and **add** your public Mapbox API key and style URL.

```json
{
  "mapbox_api_token": "YOUR PUBLIC TOKEN",
  "mapbox_style_url": "YOUR STYLE URL"
}
```

Also **add** your secret Mapbox SDK key to the system variables. For example add the following line to `.zshrc` file:

```
export SDK_REGISTRY_TOKEN="YOUR SECRET KEY"
```
