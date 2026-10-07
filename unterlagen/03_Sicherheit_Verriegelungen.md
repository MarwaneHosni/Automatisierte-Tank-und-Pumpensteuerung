# 03 – Sicherheit und Verriegelungen

Verriegelungen verhindern, dass die Anlage in einen gefährlichen oder
unsinnigen Zustand gerät. Sie gelten in **Automatik und Hand**.

![Verriegelung als KOP/FUP](../bilder/kop_fup.png)

## Verriegelungen

- **Trockenlaufschutz:** Die Pumpe läuft nur, wenn genug Wasser im Tank ist.
- **Überfüllschutz:** Ist der Tank zu voll, wird das Zulaufventil gesperrt.
- **Überlastschutz:** Meldet der **Motorschutzschalter** eine Überlast, stoppt
  die Pumpe sofort.
- **Gegenseitige Verriegelung:** Zulaufventil und Ablaufventil sind nie
  gleichzeitig offen.
- **Rückmeldung:** Bleibt die Rückmeldung von Pumpe oder Ventil aus, gibt es
  eine Störung.

## Not-Aus (Praxis)

In einer realen Anlage läuft der **Not-Aus** über einen eigenen
Sicherheitsstromkreis: Ein **Sicherheitsschaltgerät** (z. B. PNOZ) schaltet die
Antriebe **allpolig** ab. Die SPS liest das Signal nur zur **Anzeige und
Meldung** aus. So wird eine Not-Aus-Funktion sicher und unabhängig von der
normalen Steuerung umgesetzt.

> Im Modell ist diese Abschaltung logisch nachgebildet (alle Ausgänge aus).
