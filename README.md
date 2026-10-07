# Automatisierte Tank- und Pumpensteuerung mit SPS

Dieses Projekt zeigt die Steuerung einer Wasser-Anlage über eine SPS
(speicherprogrammierbare Steuerung). Es simuliert den automatischen Ablauf, die
Überwachung von Feldgeräten sowie wichtige Sicherheitsverriegelungen –
entwickelt als PC-basierte Simulation zur Erarbeitung industrieller
Steuerungskonzepte.

![Animierte Demo der Anlage](bilder/demo.gif)

## In einem Satz

Das Projekt ist das „Gehirn“ der Anlage: Es steuert Ventile und Pumpen, hält den
Füllstand im optimalen Bereich und reagiert bei Störungen sofort mit
Sicherheitsabschaltungen und Alarmen.

## Feldgeräte und Signale

Die Anlage verwendet typische Signale und Komponenten der industriellen
Steuerungstechnik:

| Feldgerät / Komponente | Funktion (einfach erklärt) | Signal- / Ansteuerungsart |
|------------------------|----------------------------|---------------------------|
| Tank | Behälter mit Füllstandsüberwachung | Analogwerteingang (4–20 mA) |
| Zulauf- & Ablaufventil | Magnetventile zum Öffnen/Schließen | Digitale Ausgänge (24 V DC / Relais) |
| Pumpe | Saugt das Wasser aus dem Tank | Pumpenschütz mit Motorschutzschalter |
| Grenzwertgeber | Schwimmschalter (fast leer / voll) | Digitale Eingänge (24 V DC) |
| Bedienelemente | Taster (Start, Stop, Reset, Not-Aus) | Digitale Eingänge (24 V DC) |
| Melder & Alarm | Leuchten (Grün/Gelb/Rot) und Hupe | Digitale Ausgänge (24 V DC) |

![Stromlaufplan / konzeptionelle Verdrahtung](bilder/stromlaufplan.png)

## Wie die Steuerung arbeitet

Die SPS arbeitet in einem festen **10-ms-Zyklus** (Hinschauen → Entscheiden →
Handeln):

- **Ablaufsteuerung:** Der Prozess folgt einem klaren Ablauf:
  **BEREIT → FÜLLEN → PROZESSBEREIT → PUMPEN → STOPPEN.**
- **Hystereseregelung:** Um ständiges Schalten zu vermeiden, füllt die Steuerung
  den Tank ab **30 %** auf und stoppt automatisch bei **80 %**.
- **Automatik / Hand:** Im Automatikbetrieb läuft die Anlage selbstständig. Im
  Handbetrieb bedient der Mensch – die Sicherheitsregeln bleiben jedoch immer
  aktiv.

![Zustandsautomat](bilder/zustandsautomat.png)

## Sicherheit und Verriegelungen

Feste Regeln verhindern Schäden an Mensch und Maschine:

- **Trockenlaufschutz:** Die Pumpe schaltet ab, bevor der Tank leer ist
  (verhindert Luftziehen).
- **Überfüllschutz:** Bei kritischem Füllstand wird das Zulaufventil sofort
  gesperrt.
- **Gegenseitige Verriegelung:** Zulauf- und Ablaufventil schalten nie
  gleichzeitig.
- **Überlastschutz:** Schlägt der Motorschutzschalter an, stoppt die Pumpe
  augenblicklich.
- **Not-Aus-Funktion:** Löst sofort die Abschaltung aller Ausgänge aus.

> Hinweis zur Praxis: In einer realen Anlage schaltet ein physisches
> Sicherheitsschaltgerät (z. B. PNOZ) die Antriebe allpolig ab; im Modell ist
> die Logik steuerungsseitig nachgebildet.

![Verriegelung als KOP/FUP](bilder/kop_fup.png)

## Störungen und Meldekonzept

Tritt ein Fehler auf, schaltet die Anlage in einen sicheren Zustand. Die Störung
wird gespeichert (rote Lampe & Hupe bleiben an), bis die Ursache behoben ist und
manuell **Reset (Quittieren)** gedrückt wird:

- **A003 (Pumpenüberlast):** Motorschutz hat ausgelöst → Pumpe aus, Alarm an.
- **A005 (Kritischer Füllstand):** Tank droht überzulaufen → Zulauf gesperrt.
- **A006 (Sensorfehler):** Unmögliche Signalkombination (z. B. „leer“ und „voll“
  zugleich) → Sicherheitsstopp.
- **A007 (Stellungsfehler):** Ventil-Rückmeldung fehlt nach 5 Sekunden →
  Störungsmeldung.

## Prozessbild (HMI) & Simulation

Eine Bedienoberfläche zeigt den Anlagenzustand in Echtzeit: Tankfüllstand,
Ventilstellungen, Pumpenstatus, Alarme und einen Füllstandsverlauf (Trend). Über
Knöpfe können Start, Stop, Reset, AUTO/HAND und der Not-Aus bedient werden.

![Prozessbild](bilder/prozessbild.png)

## Gelerntes Wissen & Praxisbezug

- **SPS-Programmierung:** Logischer Aufbau einer Ablaufsteuerung nach
  IEC 61131-3 (Structured Text) und Zustandstracking.
- **Signale & Hardware-Denkweise:** Verwertung analoger Messwerte (4–20 mA) und
  digitaler 24V-Schaltsignale.
- **Sicherheitslogik:** Umsetzung gegenseitiger Software-Verriegelungen und
  Fehlerspeicherung mit Quittierung.
- **Praxis-Transfer:** Das simulierte Logikmodell lässt sich direkt auf reale
  Steuerungen (z. B. CODESYS oder Siemens TIA Portal) und physikalische
  Schaltschränke übertragen.

---

**Unterlagen:** [Systembeschreibung](unterlagen/01_Systembeschreibung.md) ·
[E/A-Liste](unterlagen/02_EA_Liste.md) ·
[Sicherheitskonzept](unterlagen/03_Sicherheit_Verriegelungen.md) ·
[Steuerungsablauf](unterlagen/05_Steuerungsablauf.md)

Lizenz: MIT
