Nagios DRBD 9 Checks
====================

Nagios plugins for monitoring DRBD resources. The following DRBD versions
are supported:

   * DRBD 8.4.x with drbd-utils 8.9.6
   * DRBD 9.0.x with drbd-utils 8.9.6

This package contains the following Nagios checks:

   * check_drbd9.pl   - Checks DRBD resources
   * dump_drbd9.pl    - Dumps resource information (used for debugging)

Script Usage
------------

check_drbd9.pl:

        Usage: check_drbd9.pl [OPTIONS]
        OPTIONS:
          -c state        change specified state to 'CRIT' return code (example: SyncSource)
          -h              display this message
          -i pattern      include resource name or resource minor (default: all)
          -o state        change specified state to 'OKAY' return code (example: StandAlone)
          -q              quiet output
          -t              display terse details
          -V              display program version
          -v              display OKAY resources
          -w state        change specified state to 'WARN' return code (example: SyncTarget)
          -x pattern      exclude resource name or resource minor


