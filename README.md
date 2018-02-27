Nagios DRBD 9 Checks
====================

This package contains Nagios plugins for monitoring DRBD resources.  The
plugins use output from the following sources to determine the state of each
resource:

   * `/proc/drbd`
   * `/usr/sbin/drbdadm sh-resources`
   * `/usr/sbin/drbdetup events2 --now --statistics`

The following DRBD kernel modules and DRBD Utilities are supported:

   * DRBD 8.4.x with drbd-utils 8.9.6
   * DRBD 9.0.x with drbd-utils 8.9.6

This package contains the following scripts:

   * check_drbd9.pl   - Checks DRBD resources
   * dump_drbd9.pl    - Dumps resource information (used for debugging)

Script Usage
------------

check_drbd9.pl:

        Usage: check_drbd9.pl [OPTIONS]
        OPTIONS:
          -c state        change specified state to 'CRIT' (example: SyncSource)
          -d pattern      same as '-i', added for compatibility with legacy check
          -h              display this message
          -i pattern      include resource name or resource minor (default: all)
          -l              list all OKAY resources after CRIT and WARN resources
          -o state        change specified state to 'OKAY' (example: StandAlone)
          -q              quiet output
          -t              display terse details
          -V              display program version
          -v              display OKAY resources
          -w state        change specified state to 'WARN' (example: SyncTarget)
          -x pattern      exclude resource name or resource minor

        ROLE STATES:
           primary (OKAY)            secondary (OKAY)          unconfigured (CRIT)
           unknown (WARN)

        LOCAL DISK STATES:
           attaching (WARN)          consistent (OKAY)         detaching (WARN)
           diskless (CRIT)           dunknown (WARN)           failed (CRIT)
           inconsistent (CRIT)       negotiating (WARN)        outdated (CRIT)
           uptodate (OKAY)

        CONNECTION STATES:
           brokenpipe (CRIT)         connected (OKAY)          connecting (WARN)
           disconnecting (WARN)      networkfailure (CRIT)     protocolerror (CRIT)
           standalone (WARN)         teardown (WARN)           timeout (CRIT)
           unconnected (CRIT)        wfconnection (CRIT)       wfreportparams (CRIT)

        PEER DISK STATES:
           attaching (WARN)          consistent (OKAY)         detaching (WARN)
           diskless (WARN)           dunknown (WARN)           failed (WARN)
           inconsistent (WARN)       negotiating (WARN)        outdated (WARN)
           uptodate (OKAY)

        REPLICATION STATES:
           ahead (WARN)              behind (CRIT)             established (OKAY)
           off (WARN)                pausedsyncs (CRIT)        pausedsynct (CRIT)
           startingsyncs (WARN)      startingsynct (WARN)      syncsource (WARN)
           synctarget (WARN)         verifys (WARN)            verifyt (WARN)
           wfbitmaps (CRIT)          wfbitmapt (CRIT)          wfsyncuuid (WARN)


Example Output
--------------

        syzdek@hypervisor$ ./check_drbd9.pl -o StandAlone -d all -l
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

        syzdek@hypervisor$ ./check_drbd9.pl -o StandAlone -d all -l
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


Example Icinga 2 Configurations
-------------------------------

Example configuration object for Icinga 2:

     object CheckCommand "check_drbd9" {
       import "plugin-check-command"
       command = [ PluginDir + "/check_drbd9" ]
     
       arguments = {
         "-c" = { 
           value       = "$drbd9_crit_states$"
           description = "change specified state to 'CRIT' (example: SyncSource)"
         }
         "-w" = {
           value       = "$drbd9_warn_states$"
           description = "change specified state to 'WARN' (example: SyncTarget)"
         }
         "-o" = {
           value       = "$drbd9_okay_states$"
           description = "change specified state to 'OKAY' (example: StandAlone)"
         }
         "-i" = {
           value       = "$drbd9_include$"
           description = "include resource name or resource minor (default: all)"
         }
         "-x" = {
           value       = "$drbd9_exclude$"
           description = "exclude resource name or resource minor"
         }
         "-l" = {
           set_if      = "$drbd9_list_all$"
           description = "list all OKAY resources after CRIT and WARN resources"
         }
         "-v" = {
           set_if      = "$drbd9_okay$"
           description = "display OKAY resources"
         }
         "-q" = {
           set_if      = "$drbd9_quiet$"
           description = "quiet output"
         }
         "-t" = {              
           set_if      = "$drbd9_terse$"
           description = "display terse details"
         }
       }
     }


Example Nagios Configurations
-----------------------------

Example command object configurations:

        # Check all resources, treat StandAlone as OKAY
        define command{
           command_name    check_drbd
           command_line    $USER1$/check_drbd9.pl -o StandAlone -i all -l
        }

By default, all resources are checked.


DRBD service checks:

        define service{
           use                     generic-service
           host_name               hypervisorA.foo.org
           display_name            DRBD
           service_description     DRBD
           check_command           check_drbd
        }


Example NRPE Configuration
--------------------------

NRPE Configuration:

        nrpe_user=nagios
        nrpe_group=nagios

        allowed_hosts=10.0.0.0/8,127.0.0.0/8,172.16.0.0/12,192.168.0.0/16
 
        dont_blame_nrpe=0

        allow_bash_command_substitution=0

        command[check_drbd]=/usr/libexec/nagios/check_drbd -d All -o StandAlone

Due to buffer limitations of NRPE (1024 bytes as of this writting), it is
recommended that the `-l` option not be used on systems with more than than
3-4 resources.  If CRIT and WARN messages are being truncated, enable terse
output with `-t` to print each one line messages for CRIT and WARN states.

Nagios Configuration:

        define command{
                command_name    check_nrpe
                command_line    $USER1$/check_nrpe -u -H $HOSTADDRESS$ -c $ARG1$
                }


        define service{
                use                     generic-service
                host_name               hypervisorA.foo.org
                display_name            DRBD
                service_description     DRBD
                check_command           check_nrpe!check_drbd
        }

