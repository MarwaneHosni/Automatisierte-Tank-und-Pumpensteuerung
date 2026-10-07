# Automatisierte Tank- und Pumpensteuerung mit SPS

Eine kleine Anlage: Ein Tank wird automatisch gefüllt und abgepumpt. Die
Steuerung überwacht den Füllstand, schaltet **Magnetventile** und das
**Pumpenschütz** und sorgt mit **Verriegelungen** für einen sicheren Ablauf.

![Ablauf der Anlage](bilder/demo.gif)

## Warum ich das gemacht habe

Ich interessiere mich sehr für **Elektrotechnik und Steuerungstechnik**. Weil
ich noch keine eigene Anlage habe, habe ich diese Steuerung am PC aufgebaut und
durchgetestet – um zu verstehen, wie aus den Signalen von **Sensoren** die
Befehle für **Ventile und Motoren** werden und wie man gefährliche Zustände
sicher verhindert.

An echter Hardware möchte ich das praktisch lernen: **verdrahten, messen und
in Betrieb nehmen**.

## Die Anlage

- **Tank** mit Zulauf und Ablauf
- **Zulaufventil** und **Ablaufventil** (Magnetventile)
- **Pumpe**, angesteuert über ein **Pumpenschütz** und abgesichert durch einen
  **Motorschutzschalter**
- **Grenzwertgeber / Schwimmschalter** (fast leer, fast voll, zu voll)
- **Füllstandsmessung** als Analogsignal
- **Meldeleuchten** (grün/gelb/rot) und **Hupe**

Mehr dazu: [Systembeschreibung](unterlagen/01_Systembeschreibung.md)

## Signale und Feldgeräte

Die Anlage nutzt typische Industriesignale:

- **Digitale Eingänge 24 V DC** für Taster, Wahlschalter, Grenzwertgeber,
  Motorschutz und Rückmeldungen
- **Analoger Eingang 4–20 mA** für den Füllstand
- **Digitale Ausgänge** über Relais/Ventiltreiber für Ventile, Pumpenschütz und
  Melder

![Stromlaufplan](bilder/stromlaufplan.png)

Alle Signale: [E/A-Liste](unterlagen/02_EA_Liste.md)

## Steuerungsablauf

Der Ablauf ist eine **Ablaufsteuerung** in klaren Schritten:
**BEREIT → FÜLLEN → PROZESSBEREIT → PUMPEN → STOPPEN**. Damit das Zulaufventil
nicht ständig schaltet, arbeitet der Füllstand mit einer **Hysterese**
(Füllen von 30 % bis 80 %).

![Zustandsautomat](bilder/zustandsautomat.png)

Details: [Steuerungsablauf](unterlagen/05_Steuerungsablauf.md)

## Sicherheit und Verriegelungen

- **Trockenlaufschutz** – die Pumpe läuft nur bei genug Wasser.
- **Überfüllschutz** – bei zu vollem Tank wird der Zulauf gesperrt.
- **Überlastschutz** – der Motorschutz stoppt die Pumpe.
- **Gegenseitige Verriegelung** – Zulauf und Ablauf sind nie gleichzeitig offen.
- **Not-Aus** – in einer realen Anlage schaltet ein **Sicherheitsschaltgerät**
  (z. B. PNOZ) die Antriebe **allpolig** ab.

![Verriegelung als KOP/FUP](bilder/kop_fup.png)

Details: [Sicherheit und Verriegelungen](unterlagen/03_Sicherheit_Verriegelungen.md)

## Störungen und Meldungen

Jede Störung hat eine **Nummer** und wird **gespeichert**: Die rote Lampe und
die Hupe bleiben an, bis die Ursache behoben und **Reset** gedrückt wurde.
Beispiele: Pumpenüberlast (A003), Sensorfehler (A006), kritischer Füllstand
(A005).

Details: [Störungen und Meldungen](unterlagen/04_Stoerungen_Meldungen.md)

## Bedienung (HMI)

Eine Bedienoberfläche zeigt den Prozess: Tank mit Füllstand, Ventile, Pumpe,
Meldeleuchten und einen Verlauf des Füllstands. Über Tasten gibt es Start,
Stop, Reset, AUTO/HAND und Not-Aus.

![Prozessbild](bilder/prozessbild.png)

## Was ich schon verstehe – und was ich lernen will

**Verstanden (am Modell):** wie man Signale einliest und auswertet, wie eine
Ablaufsteuerung aufgebaut ist, wie Verriegelungen und Meldungen mit Quittierung
funktionieren und wie man eine SPS-Programmierung nach **IEC 61131-3** plant.

**Das möchte ich praktisch lernen:** Schaltschrankbau und Verdrahtung
nach Stromlaufplan, Arbeiten am Sicherheitsstromkreis, Messungen mit dem
Multimeter und die Inbetriebnahme realer Anlagen.

---

**Unterlagen:** [Systembeschreibung](unterlagen/01_Systembeschreibung.md) ·
[E/A-Liste](unterlagen/02_EA_Liste.md) ·
[Sicherheit und Verriegelungen](unterlagen/03_Sicherheit_Verriegelungen.md) ·
[Störungen und Meldungen](unterlagen/04_Stoerungen_Meldungen.md) ·
[Steuerungsablauf](unterlagen/05_Steuerungsablauf.md)

Lizenz: MIT
