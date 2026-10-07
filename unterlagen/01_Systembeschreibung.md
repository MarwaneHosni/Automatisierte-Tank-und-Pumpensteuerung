# 01 – Systembeschreibung

## Worum es geht

Eine kleine Anlage aus der Automatisierungstechnik: Ein **Tank** wird über ein
**Zulaufventil** gefüllt und über eine **Pumpe** wieder abgepumpt. Die Steuerung
passt auf, dass der Tank weder überläuft noch leerläuft, und hält den Ablauf
sicher.

## Die Bauteile (Elektrik)

- **Zulaufventil** (Magnetventil) – lässt Wasser in den Tank.
- **Ablaufventil** (Magnetventil) – lässt Wasser ab.
- **Pumpe** – fördert das Wasser ab, angesteuert über ein **Pumpenschütz** und
  abgesichert durch einen **Motorschutzschalter**.
- **Grenzwertgeber / Schwimmschalter** – melden „fast leer“, „fast voll“ und
  „zu voll“.
- **Füllstandsmessung** – misst den Füllstand als analoges Signal.
- **Taster und Wahlschalter** – Start, Stop, Reset, Not-Aus sowie AUTO/HAND.
- **Meldeleuchten und Hupe** – zeigen Betrieb, Warnung und Störung an.

## Betriebsarten

- **Automatik:** Die Anlage arbeitet von allein.
- **Hand:** Einzelne Aktoren lassen sich von Hand schalten – die
  Sicherheitsregeln bleiben dabei immer aktiv.

## Hinweis

Da ich noch keine eigene Anlage habe, habe ich die Steuerung und die
Verschaltung am PC aufgebaut und geprüft. Die praktische Umsetzung mit echter
Hardware möchte ich noch lernen.
