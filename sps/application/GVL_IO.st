(*
    sps/application/GVL_IO.st
    Globales Prozessabbild (simulierte Feld-E/A) sowie HMI- und
    Betriebsdaten.

    Die symbolischen Namen entsprechen dem konzeptionellen E/A-Bild.
    Die Zuordnung zu Adressen (%IX/%QX/%IW) steht in
    unterlagen/02_EA_Liste.md. In der Simulation werden die Signale
    symbolisch verwendet; die Adressen dienen der Portierung auf eine SPS.
*)

VAR_GLOBAL
    (* ---------------- Digitale Eingaenge (simuliert) ---------------- *)
    xStartBtn            : BOOL;   (* Taster Start *)
    xStopBtn             : BOOL;   (* Taster Stop *)
    xEStop               : BOOL;   (* Not-Aus (TRUE = aktiv) *)
    xResetBtn            : BOOL;   (* Taster Reset/Quittierung *)
    xModeAuto            : BOOL;   (* TRUE = Automatik, FALSE = Hand *)
    xLowLevel            : BOOL;   (* Grenzwertschalter Low *)
    xHighLevel           : BOOL;   (* Grenzwertschalter High *)
    xVeryHighLevel       : BOOL;   (* Grenzwertschalter Very-High *)
    xPumpOverload        : BOOL;   (* Motorschutz / Pumpenstoerung *)
    xPumpFeedback        : BOOL;   (* Rueckmeldung Pumpe laeuft *)
    xValveFeedbackOpen   : BOOL;   (* Rueckmeldung Zulaufventil offen *)
    xValveFeedbackClosed : BOOL;   (* Rueckmeldung Zulaufventil zu *)
    xDrainFeedbackOpen   : BOOL;   (* Rueckmeldung Ablaufventil offen *)
    xDrainFeedbackClosed : BOOL;   (* Rueckmeldung Ablaufventil zu *)
    xDemand              : BOOL;   (* Prozessbedarf (Abnehmer) *)

    (* Handbefehle (nur in Betriebsart Hand wirksam) *)
    xManPump             : BOOL;
    xManFill             : BOOL;
    xManDrain            : BOOL;

    (* ---------------- Analoge Eingaenge (simuliert) ---------------- *)
    iwLevelRaw           : INT;    (* Füllstand roh: 0..27648 *)

    (* ---------------- Digitale Ausgaenge (simuliert) ---------------- *)
    yFillValve           : BOOL;   (* Zulaufventil *)
    yPump                : BOOL;   (* Pumpe *)
    yDrainValve          : BOOL;   (* Ablaufventil *)
    yLampGreen           : BOOL;   (* Meldeleuchte gruen *)
    yLampYellow          : BOOL;   (* Meldeleuchte gelb *)
    yLampRed             : BOOL;   (* Meldeleuchte rot *)
    yBuzzer              : BOOL;   (* Hupe *)

    (* ---------------- Laufzeit / Simulationszeit ---------------- *)
    gSimTimeMs           : DINT;   (* aufsummierte Simulationszeit *)

    (* ---------------- HMI-Daten ---------------- *)
    gState               : E_State := E_State#INIT;
    gMode                : E_Mode  := E_Mode#MODE_AUTO;
    gLevelPct            : REAL;   (* berechneter Füllstand in % *)
    gPressureBar         : REAL;   (* Austrittsdruck in bar (simuliert) *)
    gAlarmId             : E_AlarmId := E_AlarmId#A_NONE;
    gAlarmSeverity       : E_Severity := E_Severity#SEV_INFO;
    gAlarmActive         : BOOL;
    gAnyCritical         : BOOL;
    gAnyWarning          : BOOL;

    (* abgeleitete Signale fuer HMI/Diagnose *)
    gFillDemand          : BOOL;
    gHighAlarm           : BOOL;
    gCriticalHigh        : BOOL;
    gCriticalLow         : BOOL;
    gSensorError         : BOOL;
    gPumpEnable          : BOOL;
    gFillEnable          : BOOL;
    gDrainEnable         : BOOL;
    gPumpFault           : BOOL;
    gValveFault          : BOOL;

    (* ---------------- Betriebsstatistik ---------------- *)
    gCycleCount          : DINT;   (* Zyklen gesamt *)
    gRunTimeMs           : DINT;   (* Betriebszeit Prozess *)
    gPumpRunTimeMs       : DINT;   (* Betriebsstunden Pumpe (ms) *)
    gFillCycles          : DINT;   (* abgeschlossene Füllzyklen *)
END_VAR
