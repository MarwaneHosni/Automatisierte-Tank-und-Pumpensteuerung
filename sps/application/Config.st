(*
    sps/application/Config.st
    Zentrale, konfigurierbare Parameter (Simulationsannahmen).

    Alle Werte sind bewusst als benannte Konstanten abgelegt und NICHT
    im Programm verstreut. Die konkreten Zahlen sind Simulationsannahmen
    und keine realen Anlagenspezifikationen.
*)

VAR_GLOBAL CONSTANT
    (* --- Zeitbasis --- *)
    SCAN_PERIOD_MS          : DINT := 10;      (* Simulations-/Taskzyklus *)

    (* --- Tank (Simulationsannahmen) --- *)
    TANK_CAPACITY_L         : REAL := 1000.0;  (* 1000 L *)

    (* --- Füllstandsschwellen in % --- *)
    LVL_LOW_PCT             : REAL := 25.0;    (* Low-Grenze *)
    LVL_FILL_START_PCT      : REAL := 30.0;    (* Start Füllen *)
    LVL_FILL_STOP_PCT       : REAL := 80.0;    (* Stopp Füllen / Ziel *)
    LVL_HIGH_ALARM_PCT      : REAL := 90.0;    (* High-Warnung *)
    LVL_CRITICAL_PCT        : REAL := 95.0;    (* Kritisch / Überfüllung *)
    LVL_CRITICAL_LOW_PCT    : REAL := 10.0;    (* Kritisch niedrig *)

    (* --- Durchflussraten (Simulation) --- *)
    FILL_RATE_PCT_PER_S     : REAL := 5.0;     (* Zulaufventil offen *)
    DRAIN_RATE_PCT_PER_S    : REAL := 4.0;     (* Pumpe aktiv *)

    (* --- Überwachungszeiten --- *)
    VALVE_FEEDBACK_TIMEOUT_MS : DINT := 5000;  (* Ventil Rückmeldung *)
    PUMP_FEEDBACK_TIMEOUT_MS  : DINT := 3000;  (* Pumpen-Rückmeldung *)
    ALARM_DELAY_MS            : DINT := 1000;  (* Alarmschwelle *)

    (* --- Anlagen-/Aktorverhalten (Simulation) --- *)
    FEEDBACK_DELAY_MS       : DINT := 300;     (* Ansprechzeit der Rückmeldung *)
    LVL_VERYHIGH_PCT        : REAL := 97.0;    (* digitaler Very-High-Grenzwert *)

    (* --- Austrittsdruck (Simulation, optional) --- *)
    PRESSURE_MAX_BAR        : REAL := 4.0;     (* max. Druck wenn Pumpe laeuft *)
    PRESSURE_RISE_BAR_PER_S : REAL := 2.0;     (* Druckanstieg bei laufender Pumpe *)
    PRESSURE_FALL_BAR_PER_S : REAL := 1.5;     (* Druckabbau bei stehender Pumpe *)

    (* --- Analoge Skalierung: Rohwert -> Prozent --- *)
    RAW_MIN                 : INT := 0;
    RAW_MAX                 : INT := 27648;    (* typischer 16-Bit-Bereich *)
    EU_MIN                  : REAL := 0.0;     (* Engineering Unit min *)
    EU_MAX                  : REAL := 100.0;   (* Engineering Unit max *)
END_VAR
