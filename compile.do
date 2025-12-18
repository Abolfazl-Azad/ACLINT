
if {[file exists work]} {
    vdel -lib work -all
}
vlib work
vmap work work

vlog -work work ./Wrapper/Input_Wrapper/*.v
vlog -work work ./Wrapper/Output_Wrapper/*.v
vlog -work work ./Wrapper/Output_Wrapper/*.sv

vlog -work work ./ACLINT/*.v
vlog -work work ./ACLINT/*.sv

