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


Example Output
--------------

        syzdek@hypervisor$ ./check_drbd9.pl   
        DRBD: 1 warn, 20 okay|
        -
        version:    8.4.7-1 (api:1/proto:86-101)
        resources:  21
        -
        lab.prv.ldaptest23 role:Secondary (WARN)
        vol:0 disk:UpToDate minor:18 size:32766MB
        vol:1 disk:UpToDate minor:19 size:65533MB
        peer role:Unknown conn:Connecting
        .. vol:0 peer:DUnknown repl:Off sync:100.00%
        .. vol:1 peer:DUnknown repl:Off sync:100.00%
        -
        lab.prv.cbrown role:Secondary (OKAY)
        lab.prv.dnstest20 role:Secondary (OKAY)
        lab.prv.dnstest21 role:Secondary (OKAY)
        lab.prv.dnstest22 role:Secondary (OKAY)
        lab.prv.dnstest23 role:Secondary (OKAY)
        lab.prv.dnstestlvs20 role:Secondary (OKAY)
        lab.prv.dnstestlvs21 role:Secondary (OKAY)
        lab.prv.drbdtest20 role:Secondary (OKAY)
        lab.prv.drbdtest21 role:Secondary (OKAY)
        lab.prv.kohfield role:Secondary (OKAY)
        lab.prv.kshymkiw role:Secondary (OKAY)
        lab.prv.ldaptest20 role:Secondary (OKAY)
        lab.prv.ldaptest21 role:Secondary (OKAY)
        lab.prv.ldaptest22 role:Secondary (OKAY)
        lab.prv.ldaptestlvs20 role:Secondary (OKAY)
        lab.prv.ldaptestlvs21 role:Secondary (OKAY)
        lab.prv.ldaptestmirror01 role:Secondary (OKAY)
        lab.prv.ldaptestmirror02 role:Secondary (OKAY)
        lab.prv.simestd role:Secondary (OKAY)
        lab.prv.wallette role:Secondary (OKAY)
        |        
        syzdek@hypervisor$

Another example:

        syzdek@hypervisor$ ./check_drbd9.pl -o StandAlone
        DRBD: 1 warn, 20 okay|
        -
        version:    9.0.2-1 (api:2/proto:86-111)
        transports: (api:14): tcp (1.0.0)
        resources:  21
        -
        lab.prv.drbdtest20 role:Primary (WARN)
        vol:0 disk:UpToDate minor:30 size:32766MB
        xen67 role:Secondary conn:Connected
        .. vol:0 peer:Inconsistent repl:SyncSource sync:11.15%
        -
        lab.prv.cbrown role:Primary (OKAY)
        lab.prv.dnstest20 role:Primary (OKAY)
        lab.prv.dnstest21 role:Secondary (OKAY)
        lab.prv.dnstest22 role:Primary (OKAY)
        lab.prv.dnstest23 role:Secondary (OKAY)
        lab.prv.dnstestlvs20 role:Primary (OKAY)
        lab.prv.dnstestlvs21 role:Secondary (OKAY)
        lab.prv.drbdtest21 role:Secondary (OKAY)
        lab.prv.kohfield role:Secondary (OKAY)
        lab.prv.kshymkiw role:Primary (OKAY)
        lab.prv.ldaptest20 role:Primary (OKAY)
        lab.prv.ldaptest21 role:Primary (OKAY)
        lab.prv.ldaptest22 role:Secondary (OKAY)
        lab.prv.ldaptest23 role:Secondary (OKAY)
        lab.prv.ldaptestlvs20 role:Primary (OKAY)
        lab.prv.ldaptestlvs21 role:Secondary (OKAY)
        lab.prv.ldaptestmirror01 role:Primary (OKAY)
        lab.prv.ldaptestmirror02 role:Secondary (OKAY)
        lab.prv.simestd role:Primary (OKAY)
        lab.prv.wallette role:Secondary (OKAY)
        |        
        syzdek@hypervisor$


Example Nagios Configurations (Command Objects)
-----------------------------------------------

Example command object configurations:

        # Check all resources, treat StandAlone as OKAY
        define command{
           command_name    check_keepalived_vrrp
           command_line    $USER1$/check_drbd.pl -o StandAlone -i all
        }

By default, all resources are checked.


Example Nagios Configurations (Service Objects)
-----------------------------------------------

DRBD service checks:

        define service{
           use                     generic-service
           host_name               hypervisorA.foo.org
           display_name            DRBD
           service_description     DRBD
           check_command           check_drbd
        }


