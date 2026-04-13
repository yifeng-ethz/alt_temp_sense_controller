package require Tcl 8.5

set script_dir [file dirname [info script]]
set helper_file [file normalize [file join $script_dir .. dashboard_infra cmsis_svd lib mu3e_cmsis_svd.tcl]]
source $helper_file

namespace eval ::mu3e::cmsis::spec {}

proc ::mu3e::cmsis::spec::build_device {} {
    set registers [list \
        [::mu3e::cmsis::svd::register CSR 0x00 \
            -description {Shared control/status word for the Arria-V on-die temperature sensor wrapper. Reads return the signed 8-bit temperature sample in bits [7:0]. Writes use bit 0 to enable or disable periodic sampling; other bits are ignored.} \
            -access read-write \
            -fields [list \
                [::mu3e::cmsis::svd::field temperature_signed 0 8 \
                    -description {Readback-only signed 8-bit Arria-V temperature code.} \
                    -access read-only] \
                [::mu3e::cmsis::svd::field reserved 8 24 \
                    -description {Reserved, read as zero and ignored on write.} \
                    -access read-only]]]]

    return [::mu3e::cmsis::svd::device MU3E_ALT_TEMP_SENSE_CTRL \
        -version 1.1 \
        -description {CMSIS-SVD description of the altera_temp_sense_ctrl wrapper CSR. BaseAddress is 0 because this file describes the relative CSR aperture of the IP; system integration supplies the live slave base address.} \
        -peripherals [list \
            [::mu3e::cmsis::svd::peripheral ALTERA_TEMP_SENSE_CTRL_CSR 0x0 \
                -description {Single-word control/status aperture for the Arria-V temperature-sense wrapper.} \
                -groupName MU3E_TEMP_SENSE \
                -addressBlockSize 0x4 \
                -registers $registers]]]
}

if {[info exists ::argv0] &&
    [file normalize $::argv0] eq [file normalize [info script]]} {
    set out_path [file join $script_dir altera_temp_sense_ctrl.svd]
    if {[llength $::argv] >= 1} {
        set out_path [lindex $::argv 0]
    }
    ::mu3e::cmsis::svd::write_device_file \
        [::mu3e::cmsis::spec::build_device] $out_path
}
