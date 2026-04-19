# Shadow Realm

Ein Pokemon/Yu-Gi-Oh-inspiriertes Rollenspiel, entwickelt mit **Godot 4**.

![Shadow Realm](build/web/index.png)

## Spielinhalt

- **18 Monster** (15 Basis-Monster + 3 Evolutionen) in 6 Typen
- **Rundenbasiertes Kampfsystem** mit Typ-Stärken/-Schwächen
- **Soul Card-Fang-System** (Normal, Silber, Gold)
- **Overworld**: Stadt + 2 Routen mit Wildgraskämpfen und NPCs
- **Vollständige UI**: Titelbildschirm, Starter-Auswahl, Kampf-UI, Team-Manager, Rucksack
- **Speichern/Laden** per JSON

## Spielen im Browser

Das Spiel ist als HTML5/WebAssembly-Export verfügbar und läuft direkt im Browser — kein Download nötig.

> Die Web-Version befindet sich im Ordner `build/web/`.

### Lokal starten (MacBook / Linux / Windows)

**Voraussetzung:** Ein lokaler HTTP-Server ist nötig (einfaches Doppelklick auf `index.html` funktioniert nicht, da Godot WASM spezielle HTTP-Header benötigt).

```bash
# In den Web-Build-Ordner wechseln
cd build/web

# Server starten
./serve.sh

# Browser öffnen
# http://localhost:8080
```

Alternativ mit Python:
```bash
cd build/web
python3 -m http.server 8080
# Hinweis: Python's SimpleHTTPServer setzt NICHT die nötigen COOP/COEP-Header.
# Nutze serve.sh für das korrekte Setup.
```

### Steuerung

| Taste | Aktion |
|-------|--------|
| W / Pfeil oben | Nach oben gehen |
| S / Pfeil unten | Nach unten gehen |
| A / Pfeil links | Nach links gehen |
| D / Pfeil rechts | Nach rechts gehen |
| Leertaste / Enter | Interagieren / Bestätigen |

## In Godot 4 öffnen

1. [Godot 4](https://godotengine.org/download/) herunterladen und installieren (Version 4.2+)
2. Dieses Repository klonen: `git clone https://github.com/Jarvis-6587/shadow-realm.git`
3. Godot 4 starten → **Import** → Ordner `shadow-realm/` auswählen → `project.godot` öffnen
4. Auf **Play** (F5) klicken

## Projektstruktur

```
shadow-realm/
├── project.godot          # Godot-Projektdatei
├── export_presets.cfg     # Export-Konfiguration (HTML5)
├── assets/                # Grafiken, Sounds
├── scenes/                # .tscn Szenen-Dateien
│   ├── title_screen.tscn
│   ├── overworld.tscn
│   ├── battle.tscn
│   └── ...
├── scripts/               # GDScript-Dateien
│   ├── game_data.gd       # Monster, Angriffe, Typen (Autoload)
│   ├── game_state.gd      # Spielstand (Autoload)
│   ├── battle.gd
│   ├── overworld.gd
│   └── ...
├── data/                  # JSON-Datendateien
└── build/
    └── web/               # HTML5/WASM-Export
        ├── index.html
        ├── index.wasm
        ├── index.pck
        └── serve.sh
```

## Download (Web-Build als ZIP)

Den fertigen Web-Build als ZIP findest du unter [Releases](https://github.com/Jarvis-6587/shadow-realm/releases).

---

*Entwickelt mit Godot 4.2 · GDScript*
