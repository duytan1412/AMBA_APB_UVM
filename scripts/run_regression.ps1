param(
    [ValidateSet('vcs','xcelium')]
    [string]$Simulator = 'xcelium',
    [string[]]$Tests = @('apb_base_test', 'apb_random_test', 'apb_error_test', 'apb_b2b_test')
)

$ErrorActionPreference = 'Stop'
$repo = Split-Path -Parent $PSScriptRoot
Set-Location $repo
New-Item -ItemType Directory -Force -Path 'sim_results' | Out-Null

foreach ($test in $Tests) {
    Write-Host "Running $test with $Simulator"
    if ($Simulator -eq 'xcelium') {
        xrun -sv -uvm -incdir tb/uvm rtl/apb_ram.sv tb/uvm/tb_top.sv "+UVM_TESTNAME=$test" -l "sim_results/$test.log"
    } else {
        vcs -full64 -sverilog -ntb_opts uvm +incdir+tb/uvm rtl/apb_ram.sv tb/uvm/tb_top.sv -R "+UVM_TESTNAME=$test" -l "sim_results/$test.log"
    }
}
